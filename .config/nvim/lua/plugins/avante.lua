-- Avante.nvim - AI-powered code assistant similar to Cursor IDE
return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false, -- 不要设为 "*"
  -- 使用 make 构建
  build = "make",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- 可选依赖
    "nvim-mini/mini.pick",
    "nvim-telescope/telescope.nvim",
    "Kaiser-Yang/blink-cmp-avante", -- autocompletion for avante commands and mentions
    "ibhagwan/fzf-lua",
    "folke/snacks.nvim",
    "nvim-tree/nvim-web-devicons",
    {
      -- 支持图片粘贴（仅限 Markdown 和 Avante 文件）
      "HakonHarnes/img-clip.nvim",
      ft = { "markdown", "Avante" }, -- 仅在指定文件类型加载
      opts = {
        -- 推荐设置
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- macOS 优化：优先使用 pngpaste
          use_absolute_path = true,
        },
        -- 仅在特定文件类型中启用
        filetypes = {
          markdown = {
            url_encode_path = true,
            template = "![]($FILE_PATH)",
          },
          Avante = {
            template = "![]($FILE_PATH)",
          },
        },
      },
    },
    {
      -- 确保 render-markdown.nvim 支持 Avante 文件类型
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
  opts = {
    ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
    -- 【当前默认: Claude Opus 4.8】通过 Anthropic 原生接口反代调用。
    provider = "grok-build",
    -- provider = "claude-opus",
    -- auto_suggestions_provider = "xai",

    -- 【当前: agentic】avante 自带 agentic 循环 —— 用真工具自动读写文件、多步迭代(这才能真落盘)。
    -- ⚠️ 死循环教训(保留): agentic 一个回合只在模型调用 attempt_completion 时才结束;非 Claude 模型
    --   常写完正文却不调那个工具 → avante 注入"You should use attempt_completion"反复催 →
    --   无限循环(zig_gemini 实测 146 条消息全困在里面)。
    --   规避: provider 保持真 Claude(claude-opus 会正确调 attempt_completion);跑非 Claude(gpt/glm)
    --   前先掂量这个坑。卡循环就 <C-c>/<Esc>/q 取消,或改回 mode = "legacy" 退回问答/教学。
    mode = "agentic",

    -- 系统提示词 - 强制使用中文回复
    system_prompt = "你是一个专业的 AI 编程助手。你必须始终使用中文回复用户的所有问题和请求。无论用户使用什么语言提问，你都要用中文回答。请提供清晰、准确、有用的编程建议，代码注释和说明都使用中文。",

    -- AI 提供商配置
    providers = {
      -- Claude Opus 4.8 反代（Anthropic 原生接口）
      ["claude-opus"] = {
        __inherited_from = "claude",
        endpoint = "https://1a7432.site/claude-avante",
        api_key_name = "ANTHROPIC_API_KEY", -- 优先读取 AVANTE_ANTHROPIC_API_KEY
        model = "claude-opus-4-8",
        timeout = 120000,
        extra_request_body = {
          output_config = { effort = "xhigh" }, -- ← 思考强度：low/medium/high/xhigh/max
          thinking = { type = "adaptive" }, -- ← 让思考过程能流式显示（可选）
        },
      },
      -- ikun.cc 中转站 - Claude Sonnet 4.6 (使用 Anthropic 原生接口)
      ikun = {
        __inherited_from = "claude", -- 继承 Claude 原生接口
        endpoint = "https://api.ikuncode.cc", -- ikun.cc 中转站地址(更稳定)
        api_key_name = "ANTHROPIC_AUTH_TOKEN", -- 使用 zshrc 中的 token
        model = "claude-sonnet-4-6", -- Claude Sonnet 4.6 (如中转站暂不支持可回退 claude-sonnet-4-5-20250929)
        timeout = 60000, -- 60秒超时
      },
      -- ikun.cc 中转站 - GPT-5.1 Codex Max (使用 OpenAI 接口)
      ["ikun-gpt"] = {
        __inherited_from = "openai", -- 继承 OpenAI 接口
        endpoint = "https://api.ikuncode.cc/v1", -- OpenAI 接口需要 /v1 路径
        api_key_name = "IKUN_OPENAI_API_KEY", -- 使用单独的 OpenAI key
        model = "gpt-5.1-codex-max", -- GPT-5.1 Codex Max (支持 128k 输出)
        timeout = 120000, -- 120秒超时,给长输出足够时间
        -- 不设置 temperature 和 max_tokens,使用模型默认值(遵循 Codex 源码设计)
      },
      -- ikun.cc 中转站 - GPT-5 High (使用 OpenAI 接口)
      ["ikun-gpt5"] = {
        __inherited_from = "openai", -- 继承 OpenAI 接口
        endpoint = "https://api.ikuncode.cc/v1", -- OpenAI 接口需要 /v1 路径
        api_key_name = "IKUN_OPENAI_API_KEY", -- 使用单独的 OpenAI key
        model = "gpt-5.1", -- GPT-5 High
        timeout = 60000, -- 60秒超时
      },
      -- Moonshot
      moonshot = {
        endpoint = "https://api.moonshot.cn/v1",
        model = "kimi-k2.7-code",
        timeout = 30000,
      },
      -- xAI Grok（已停用，保留供回滚）
      -- xai = {
      --   model = "grok-build-0.1",
      --   timeout = 30000,
      -- },
      -- GLM-5.1 智谱AI
      glm = {
        __inherited_from = "openai",
        endpoint = "https://open.bigmodel.cn/api/coding/paas/v4",
        model = "glm-5.1",
        api_key_name = "GLM_API_KEY",
        timeout = 30000,
      },
      -- DeepSeek(已注释,随时可回滚为侧边栏默认): key 在 zshrc $DEEPSEEK_API_KEY。
      -- V4 世代仅两档(老 deepseek-chat/reasoner 别名已废): pro=强, flash=快而更省。
      deepseek = {
        __inherited_from = "openai",
        endpoint = "https://api.deepseek.com",
        model = "deepseek-v4-pro", -- 侧边栏嫌慢/省钱可换 "deepseek-v4-flash"(两者都是推理模型)
        api_key_name = "DEEPSEEK_API_KEY",
        timeout = 30000,
      },
    },

    acp_providers = {
      ["claude-code"] = {
        -- 官方适配器 claude-agent-acp,内嵌现役 agent-sdk 0.3.197。
        -- 勿切 zed 家的 claude-code-acp 0.10.3:它内嵌 2025-10 的旧引擎(claude-code 2.0.37),
        -- 模型列表是化石(Sonnet 4.5/Opus 4.1 年代)。
        -- 【实测 2026-07-14】ACP_PERMISSION_MODE / ACP_PATH_TO_CLAUDE_CODE_EXECUTABLE 两个适配器都不读,
        -- 是历史死变量,已清除。权限模式只能会话内切:<leader>am 选 bypassPermissions
        -- ——default 模式下工具权限确认弹窗易被错过,表现为永远 generating(卡死病根)。
        -- 模型选择:用各项目 .claude/settings.json 的 "model" 字段(SDK 会读),不在这里配。
        command = "claude-agent-acp",
        args = {},
        env = {
          NODE_NO_WARNINGS = "1",
          -- 订阅结算: SDK/node 进程读不到 claude CLI 写的钥匙串条目(ACL 只认创建者),
          -- 用 `claude setup-token` 的长效 OAuth token(仍订阅计费)喂给子进程;
          -- token 在 ~/.config/claude/acp_oauth_token(chmod 600, 单独一行)。
          -- 注意: 全局 export ANTHROPIC_API_KEY/ANTHROPIC_AUTH_TOKEN 会泄漏进子进程强制走 API 计费
          CLAUDE_CODE_OAUTH_TOKEN = (vim.fn.filereadable(vim.fn.expand("~/.config/claude/acp_oauth_token")) == 1)
              and vim.fn.readfile(vim.fn.expand("~/.config/claude/acp_oauth_token"))[1]
            or nil,
        },
        timeout = 20000, -- 20秒超时
      },
      -- Grok Build
      ["grok-build"] = {
        command = "grok",
        args = { "agent", "stdio" },
      },
      -- ["codex"] = { command = "codex-acp", args = {} },
    },

    -- 会话恢复配置
    session_recovery = {
      enabled = false, -- 临时禁用会话恢复，解决无限循环重复问题
      max_history_messages = 20, -- 恢复时最多保留的历史消息数
      max_message_length = 1000, -- 单条消息最大长度
      include_history_count = 15, -- 会话恢复时包含的消息数
      truncate_history = true, -- 默认截断历史，避免超出ACP上下文限制
    },

    -- 调试配置
    debug = false, -- 普通日志级别

    -- 行为配置
    behaviour = {
      auto_suggestions = false, -- 自动补全改由 neocodeium 提供
      auto_set_highlight_group = true,
      auto_set_keymaps = true, -- 自动设置快捷键
      auto_apply_diff_after_generation = false,
      support_paste_from_clipboard = false, -- 禁用以避免与 unnamedplus 冲突
      minimize_diff = true, -- 应用代码块时移除未更改的行
    },

    -- 快捷键映射配置
    mappings = {
      files = {
        add_current = "<leader>ab",
        add_all_buffers = "<leader>aB",
      },
      --- @class AvanteConflictMappings
      diff = {
        ours = "co",
        theirs = "ct",
        all_theirs = "ca",
        both = "cb",
        cursor = "cc",
        next = "]x",
        prev = "[x",
      },
      suggestion = {
        accept = "<M-l>",
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-]>",
      },
      jump = {
        next = "]]",
        prev = "[[",
      },
      submit = {
        normal = "<CR>",
        insert = "<C-s>",
      },
      cancel = {
        normal = { "<C-c>", "<Esc>", "q" },
        insert = { "<C-c>" },
      },
      sidebar = {
        apply_all = "A",
        apply_cursor = "a",
        retry_user_request = "r",
        edit_user_request = "e",
        switch_windows = "<Tab>",
        reverse_switch_windows = "<S-Tab>",
        remove_file = "d",
        add_file = "@",
        close = { "<Esc>", "q" },
      },
    },

    -- 窗口配置
    windows = {
      position = "right", -- 侧边栏位置：right | left | top | bottom
      wrap = true, -- 类似 vim.o.wrap
      width = 30, -- 基于可用宽度的百分比
      sidebar_header = {
        enabled = true, -- 启用侧边栏头部
        align = "center", -- left, center, right
        rounded = true,
      },
      input = {
        prefix = "> ",
        height = 8, -- 垂直布局中输入窗口的高度
      },
      edit = {
        border = "rounded",
        start_insert = true, -- 打开编辑窗口时启动插入模式
      },
      ask = {
        floating = false, -- 在浮动窗口中打开 'AvanteAsk' 提示
        start_insert = true, -- 打开询问窗口时启动插入模式
        border = "rounded",
        focus_on_apply = "ours", -- 应用后聚焦哪个差异："ours" | "theirs"
      },
    },

    -- 选择配置
    selection = {
      enabled = true,
      hint_display = "delayed",
    },

    -- 项目指令文件配置
    -- Avante 当前无法用 nil 禁用该项；显式使用独立的 avante.md，避免误读 AGENTS.md。
    instructions_file = "avante.md",

    -- 输入提供程序配置
    input = {
      provider = "snacks", -- 使用 snacks.nvim 提供增强的输入 UI
      provider_opts = {},
    },

    -- 文件选择器配置
    selector = {
      provider = "fzf_lua", -- native | fzf_lua | mini_pick | snacks | telescope
      provider_opts = {},
    },
  },

  -- 中文友好的快捷键配置
  keys = {
    { "<leader>a", "", desc = "🤖 AI 助手" },
    {
      "<leader>aa",
      function()
        require("avante.api").ask()
      end,
      desc = "AI 对话",
      mode = { "n", "v" },
    },
    {
      "<leader>ar",
      function()
        require("avante.api").refresh()
      end,
      desc = "刷新对话",
    },
    {
      "<leader>ae",
      function()
        require("avante.api").edit()
      end,
      desc = "编辑代码",
      mode = "v",
    },
    {
      "<leader>af",
      function()
        require("avante").toggle()
      end,
      desc = "切换侧边栏",
    },
    {
      "<leader>ac",
      "<cmd>AvanteClear<cr>",
      desc = "清除历史",
    },
    {
      "<leader>as",
      function()
        require("avante").toggle.suggestion()
      end,
      desc = "切换建议",
    },
    {
      "<leader>am",
      function()
        require("avante.api").select_acp_mode()
      end,
      desc = "ACP 权限模式(卡 generating 时切 bypassPermissions)",
    },

    -- 文件管理快捷键
    {
      "<leader>ab",
      function()
        local api = require("avante.api")
        local sidebar = require("avante").get()
        if not sidebar then
          api.ask()
          sidebar = require("avante").get()
        end
        if not sidebar:is_open() then
          sidebar:open({})
        end
        sidebar.file_selector:add_current_buffer()
      end,
      desc = "添加当前缓冲区",
    },
    {
      "<leader>aB",
      function()
        require("avante.api").add_buffer_files()
      end,
      desc = "添加所有缓冲区",
    },

    -- 模型和提供商切换
    -- 注意：使用 <leader>a? 来选择模型（内置映射）
    {
      "<leader>aN",
      "<cmd>AvanteChatNew<cr>",
      desc = "新对话",
    },
    {
      "<leader>ah",
      "<cmd>AvanteHistory<cr>",
      desc = "对话历史",
    },
  },

  -- 确保在 colorscheme 之后加载
  config = function(_, opts)
    -- Grok ACP 私有通知兼容补丁（已停用，保留供回滚）
    local ok, ACPClient = pcall(require, "avante.libs.acp_client")
    if ok and type(ACPClient) == "table" and not ACPClient.__grok_notify_patched then
      local orig = ACPClient._handle_notification
      if type(orig) == "function" then
        ACPClient._handle_notification = function(self, message_id, method, params)
          if type(method) == "string" and method:sub(1, 1) == "_" then
            return
          end
          return orig(self, message_id, method, params)
        end
        ACPClient.__grok_notify_patched = true
      end
    end

    require("avante").setup(opts)
  end,
}
