-- Avante.nvim - AI-powered code assistant similar to Cursor IDE
return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  lazy = false,
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
      ft = { "markdown", "avante" }, -- 仅在指定文件类型加载
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
          avante = {
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
    provider = "claude-code",
    auto_suggestions_provider = "xai",

    -- 系统提示词 - 强制使用中文回复
    system_prompt = "你是一个专业的AI编程助手。你必须始终使用中文回复用户的所有问题和请求。无论用户使用什么语言提问，你都要用中文回答。请提供清晰、准确、有用的编程建议，代码注释和说明都使用中文。",

    -- AI 提供商配置
    providers = {
      -- 自定义 nekro provider，继承自 openai
      nekro = {
        __inherited_from = "openai", -- 继承 openai 的所有功能
        endpoint = "https://api.nekro.ai/v1", -- nekro.ai 代理 Claude
        model = "claude-sonnet-4-20250514-thinking", -- Claude 4 Sonnet
        timeout = 30000,
        extra_request_body = {
          temperature = 0.7,
          max_tokens = 20480,
        },
      },
      -- Moonshot
      moonshot = {
        endpoint = "https://api.moonshot.cn/v1",
        model = "kimi-k2-0905-preview",
        timeout = 30000,
        extra_request_body = {
          temperature = 0.5,
          max_tokens = 128000,
        },
      },
      -- xAI Grok
      xai = {
        timeout = 30000,
        extra_request_body = {
          temperature = 0.3, -- 低温度确保代码生成的准确性和确定性
          max_tokens = 32768, -- 支持更长的代码生成，最大 256k tokens
        },
      },
    },

    acp_providers = {
      ["claude-code"] = {
        command = "claude-code-acp",
        args = {},
        env = {
          NODE_NO_WARNINGS = "1",
          -- CLAUDE_CODE_OAUTH_TOKEN = os.getenv("CLAUDE_CODE_OAUTH_TOKEN"),
          ANTHROPIC_BASE_URL = os.getenv("ANTHROPIC_BASE_URL"),
          ANTHROPIC_AUTH_TOKEN = os.getenv("ANTHROPIC_AUTH_TOKEN"),
        },
        timeout = 20000, -- 20秒超时
      },
      ["gemini-cli"] = {
        command = "gemini",
        args = { "--experimental-acp" },
        env = {
          NODE_NO_WARNINGS = "1",
          GEMINI_API_KEY = os.getenv("GEMINI_API_KEY"),
        },
      },
    },


    -- 会话恢复配置
    session_recovery = {
      enabled = true, -- 启用 ACP 会话自动恢复
      max_history_messages = 20, -- 恢复时最多保留的历史消息数
      max_message_length = 1000, -- 单条消息最大长度
      include_history_count = 15, -- 会话恢复时包含的消息数
      truncate_history = true, -- 默认截断历史，避免超出ACP上下文限制
    },

    -- 调试配置
    debug = true, -- 启用调试日志

    -- 行为配置
    behaviour = {
      auto_suggestions = false,
      auto_set_highlight_group = true,
      auto_set_keymaps = true, -- 自动设置快捷键
      auto_apply_diff_after_generation = false,
      support_paste_from_clipboard = false, -- 禁用以避免与 unnamedplus 冲突
      minimize_diff = true, -- 应用代码块时移除未更改的行
    },

    -- 快捷键映射配置
    mappings = {
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
    instructions_file = "AGENTS.md", -- 项目根目录的指令文件

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

    -- RAG Service 配置
    rag_service = {
      enabled = true, -- 启用RAG服务
      host_mount = os.getenv("HOME"), -- 挂载用户主目录
      runner = "docker", -- 使用docker运行器（OrbStack兼容）
      llm = { -- RAG服务的语言模型配置
        provider = "openai",
        endpoint = "https://api.nekro.ai",
        api_key = "NEKRO_API_KEY", -- 环境变量名称
        model = "deepseek-v3-250324",
        extra = nil,
      },
      embed = { -- RAG服务的嵌入模型配置
        provider = "openai",
        endpoint = "https://api.nekro.ai",
        api_key = "NEKRO_API_KEY", -- 环境变量名称
        model = "text-embedding-v3",
        extra = nil,
      },
      docker_extra_args = "", -- Docker额外参数
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
      function()
        require("avante").toggle.clear_history()
      end,
      desc = "清除历史",
    },
    {
      "<leader>as",
      function()
        require("avante").toggle.suggestion()
      end,
      desc = "切换建议",
    },

    -- 文件管理快捷键
    {
      "<leader>ab",
      function()
        require("avante.api").add_current_buffer()
      end,
      desc = "添加当前缓冲区",
    },
    {
      "<leader>aB",
      function()
        require("avante.api").add_all_buffers()
      end,
      desc = "添加所有缓冲区",
    },

    -- 模型和提供商切换
    -- 注意：使用 <leader>a? 来选择模型（内置映射）
    {
      "<leader>aN",
      function()
        require("avante.api").new_chat()
      end,
      desc = "新对话",
    },
    {
      "<leader>ah",
      function()
        require("avante.api").history()
      end,
      desc = "对话历史",
    },
  },

  -- 确保在 colorscheme 之后加载
  config = function(_, opts)
    require("avante").setup(opts)
  end,
}
