-- CodeCompanion.nvim - AI 编程助手（替代 avante.nvim）
--
-- 配置键名注意：当前版本用 `interactions`（不是老版本的 `strategies`），
-- 适配器分 `adapters.http`（走 HTTP API）和 `adapters.acp`（走 Agent Client Protocol 子进程）两个命名空间。
return {
  "olimorris/codecompanion.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "ibhagwan/fzf-lua", -- slash command / action palette 选择器
    "folke/snacks.nvim", -- 输入 UI
    {
      -- 渲染对话缓冲区的 markdown（filetype 为 codecompanion）
      "MeanderingProgrammer/render-markdown.nvim",
      opts = { file_types = { "markdown", "codecompanion" } },
      ft = { "markdown", "codecompanion" },
    },
  },

  opts = {
    adapters = {
      -- ACP：真 agentic 循环，子进程自己读写文件、多步迭代
      acp = {
        -- Grok Build（xAI 官方 CLI 的 ACP 模式）—— chat 默认走这里。
        -- 认证：**只走订阅**（grok.com OIDC 登录，token 在 ~/.grok/auth.json）。
        --       grok 的凭据优先级是 XAI_API_KEY 环境变量 > 缓存 token，而子进程会继承 nvim 的环境，
        --       zshrc 里 export 了 XAI_API_KEY —— 不处理的话会被按 API 计费。
        --       所以命令用 `env -u XAI_API_KEY` 包一层，把这个变量从子进程环境里摘掉。
        --       （vim.system 的 env 是「在父环境上叠加」，没法删除变量，只能靠 env -u。）
        --       验证：`env -u XAI_API_KEY grok models` 应显示 "You are logged in with grok.com."
        --       handlers.auth 直接返回 true，跳过 ACP 的 authenticate 往返，让 grok 自己解析凭据。
        -- 模型：grok 的 ACP 用的是**旧版** session/new -> `models` 字段（不是新版 configOptions），
        --       CodeCompanion 的模型选择器只认 configOptions + session/set_config_option，
        --       所以这里**不要**写 defaults.session_config_options.model —— 会报
        --       "Agent does not support changing models"。
        --       模型由 ~/.grok/config.toml 的 [models] default 决定（当前 grok-4.6，最新档），
        --       reasoning effort 同样走那里的 default_reasoning_effort = "xhigh"。
        --       换模型就改 config.toml，grok TUI 和这里共用一份配置。
        -- 权限：--always-approve 等同 claude_code 那边的 bypassPermissions。
        --       想留一道闸门就删掉这个参数（但漏点确认会表现为一直 generating）。
        grok = function()
          return {
            name = "grok",
            formatted_name = "Grok",
            type = "acp",
            roles = { llm = "assistant", user = "user" },
            opts = {
              vision = false, -- 实测 initialize 返回 promptCapabilities.image = false
            },
            commands = {
              default = { "env", "-u", "XAI_API_KEY", "grok", "agent", "--always-approve", "stdio" },
            },
            defaults = {
              mcpServers = {},
              timeout = 30000,
            },
            parameters = {
              protocolVersion = 1,
              clientCapabilities = {
                fs = { readTextFile = true, writeTextFile = true },
              },
              clientInfo = {
                name = "CodeCompanion.nvim",
                version = "1.0.0",
              },
            },
            handlers = {
              setup = function()
                return true
              end,
              auth = function()
                return true
              end,
              form_messages = function(self, messages, capabilities)
                return require("codecompanion.adapters.acp.helpers").form_messages(self, messages, capabilities)
              end,
              on_exit = function() end,
            },
          }
        end,

        -- Claude Code ACP —— 已抛弃，定义保留供回滚。启用后把 interactions.chat.adapter 改回 "claude_code"。
        claude_code = function()
          return require("codecompanion.adapters").extend("claude_code", {
            env = {
              -- 订阅结算：node 子进程读不到 claude CLI 写的钥匙串条目（ACL 只认创建者），
              -- 所以用 `claude setup-token` 生成的长效 OAuth token（仍按订阅计费）。
              -- token 在 ~/.config/claude/acp_oauth_token（chmod 600，单独一行）。
              -- "file:" 前缀是 CodeCompanion 的 env 解析语法：读文件内容并去掉尾部空白。
              --
              -- ⚠️ 子进程会继承 nvim 的环境变量。若将来在 zshrc 里 export
              --    ANTHROPIC_API_KEY / ANTHROPIC_AUTH_TOKEN，会泄漏进来并可能强制走 API 计费。
              --    当前 zshrc 只有 AVANTE_ANTHROPIC_API_KEY，不受影响。
              CLAUDE_CODE_OAUTH_TOKEN = "file:~/.config/claude/acp_oauth_token",
            },
            defaults = {
              timeout = 30000, -- 30 秒握手超时（默认 20s，冷启动偏紧）

              -- 权限模式。不设的话默认是 auto（模型分类器逐次判断放行/拒绝），
              -- 遇到写文件、跑命令这类操作会走 session/request_permission 弹窗，
              -- 漏点确认就表现为卡住或 "session prompt failed"。
              --
              -- 可选：auto | default(手动) | acceptEdits(自动接受编辑) |
              --       plan(只规划) | dontAsk | bypassPermissions(全放行)
              -- ⚠️ bypassPermissions = 不做任何权限检查，agent 可直接改文件/执行命令。
              --    想留一道闸门就换成 "acceptEdits"。
              --
              -- 注意用 session_config_options.mode，不要用顶层 defaults.mode
              -- （后者是 legacy 字段，上游标记 v20.0.0 移除）。
              session_config_options = {
                mode = "bypassPermissions",
              },
            },
          })
        end,
      },

      -- HTTP：普通问答 / 内联编辑，按 token 计费
      http = {
        -- Grok 反代（OpenAI 兼容接口）—— 内联编辑 / 命令行生成走这里。
        -- 为什么不用 ACP：CodeCompanion 的 inline/cmd 源码里硬性要求 adapter.type == "http"
        --   （interactions/inline/init.lua:208、cmd.lua:27），ACP 适配器会被直接拒掉，
        --   所以侧边栏对话走 grok ACP，内联这条只能走 HTTP。
        -- key 和反代地址都不写进仓库（dotfiles 会 commit）：
        --   ~/.config/grok/proxy_api_key —— key（chmod 600，单独一行）
        --   ~/.config/grok/proxy_url     —— 反代 base，不带 /v1（chmod 600，单独一行）
        --   "file:" 是 CodeCompanion 的 env 解析语法，读文件内容并去掉尾部空白；url 里的 ${proxy_url} 取自 env。
        -- 反代实测：GET /v1/models 正常，chat/completions 支持 stream=true 的 SSE。
        grok_proxy = function()
          return require("codecompanion.adapters").extend("xai", {
            name = "grok_proxy",
            formatted_name = "Grok (proxy)",
            url = "${proxy_url}/v1/chat/completions",
            env = {
              proxy_url = "file:~/.config/grok/proxy_url",
              api_key = "file:~/.config/grok/proxy_api_key",
            },
            schema = {
              model = {
                default = "grok-4.6", -- 反代 /v1/models 里最新的一档
                choices = {
                  "grok-4.6",
                  "grok-4.5",
                  "grok-4.3",
                  "grok-build-0.1",
                  "grok-composer-2.5-fast",
                  "grok-3-mini",
                },
              },
            },
          })
        end,

        -- DeepSeek（已不再默认使用，保留供回滚）
        deepseek = function()
          return require("codecompanion.adapters").extend("deepseek", {
            -- key 在 zshrc 的 $DEEPSEEK_API_KEY
            -- V4 世代仅两档（老 deepseek-chat/reasoner 别名已废）：pro=强，flash=快而更省
            env = { api_key = "DEEPSEEK_API_KEY" },
            schema = { model = { default = "deepseek-v4-pro" } },
          })
        end,

        -- Claude Opus 5 反代（保留供回滚；启用后把下面 interactions 里的 adapter 改成 "claude_opus"）
        -- 两个坑：
        --   1. CodeCompanion 不做 AVANTE_ 前缀回退，要显式写 key 名。
        --   2. url 是完整端点（内置 anthropic 是 .../v1/messages），avante 那边只写到 base，
        --      下面的路径需按反代实际情况核对。
        --   反代 base 同样不进仓库：~/.config/claude/proxy_url（chmod 600，单独一行）。
        -- claude_opus = function()
        --   return require("codecompanion.adapters").extend("anthropic", {
        --     url = "${proxy_url}/v1/messages",
        --     env = {
        --       proxy_url = "file:~/.config/claude/proxy_url",
        --       api_key = "AVANTE_ANTHROPIC_API_KEY",
        --     },
        --     schema = { model = { default = "claude-opus-5" } },
        --   })
        -- end,
      },
    },

    interactions = {
      -- 侧边栏对话：走 Grok Build ACP（grok.com 订阅，能真落盘）
      -- 回滚 Claude Code 就把这里改成 "claude_code"
      chat = { adapter = "grok" },
      -- 内联编辑 / 命令行生成：ACP 不适用（源码只收 http），走 Grok 反代
      inline = { adapter = "grok_proxy" },
      cmd = { adapter = "grok_proxy" },
    },

    display = {
      chat = {
        -- 默认是 false（普通模式打开）。但普通模式下 <CR> 就是「发送」，
        -- 刚打开就按回车 = 发空消息 -> API 400 "user messages must have non-empty content"。
        -- 对齐原 avante ask/edit 窗口的 start_insert = true。
        start_in_insert_mode = true,
        window = {
          layout = "vertical",
          position = "right",
          width = 0.35,
        },
      },
      diff = {
        enabled = true,
      },
    },

    opts = {
      language = "Chinese", -- 取代 avante 的 system_prompt「始终使用中文回复」
      log_level = "ERROR",
    },
  },

  -- 中文友好的快捷键（沿用原 avante 的 <leader>a 前缀）
  keys = {
    { "<leader>a", "", desc = "🤖 AI 助手" },
    {
      "<leader>aa",
      "<cmd>CodeCompanionChat Toggle<cr>",
      desc = "切换 AI 对话",
      mode = { "n", "v" },
    },
    {
      "<leader>an",
      "<cmd>CodeCompanionChat<cr>",
      desc = "新建对话",
    },
    {
      "<leader>ap",
      "<cmd>CodeCompanionActions<cr>",
      desc = "动作面板",
      mode = { "n", "v" },
    },
    {
      "<leader>ae",
      ":CodeCompanion ",
      desc = "内联编辑（输入指令后回车）",
      mode = { "n", "v" },
    },
    {
      "<leader>ab",
      ":CodeCompanionChat Add<cr>",
      desc = "把选区加入对话",
      mode = "v",
    },
    {
      "<leader>ac",
      ":CodeCompanionCmd ",
      desc = "生成命令行",
    },
    {
      "<leader>ar",
      "<cmd>CodeCompanionCodeReview<cr>",
      desc = "代码审查",
    },
  },
}
