-- Avante.nvim - AI-powered code assistant similar to Cursor IDE
return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  lazy = false,
  version = false, -- 不要设为 "*"
  -- 使用 make 构建
  build = "make",
  dependencies = {
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- 可选依赖
    "echasnovski/mini.pick",
    "nvim-telescope/telescope.nvim",
    "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
    "ibhagwan/fzf-lua",
    "folke/snacks.nvim",
    "nvim-tree/nvim-web-devicons",
    {
      -- 支持图片粘贴
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- 推荐设置
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- Windows 用户必需
          use_absolute_path = true,
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
    provider = "openai", -- 默认使用 openai provider (通过 nekro.ai 访问 Claude)
    auto_suggestions_provider = "openai", -- 自动建议也使用 openai

    -- AI 提供商配置
    providers = {
      -- 使用 openai provider 配置第三方 API
      openai = {  -- 必须使用 "openai" 作为名称
        endpoint = "https://api.nekro.ai/v1", -- nekro.ai 代理 Claude
        model = "claude-sonnet-4-20250514-thinking", -- Claude 4 Sonnet
        timeout = 30000,
        temperature = 0.75,
        max_tokens = 20480,
      },
      -- Moonshot 作为备用 provider，需要手动切换
      moonshot = {
        endpoint = "https://api.moonshot.cn/v1",
        model = "kimi-k2-0905-preview",
        timeout = 30000,
        temperature = 0.6,
        max_tokens = 256000,
      },
    },

    -- 行为配置
    behaviour = {
      auto_suggestions = false, -- 暂时禁用自动建议（实验性功能）
      auto_set_highlight_group = true,
      auto_set_keymaps = true, -- 自动设置快捷键
      auto_apply_diff_after_generation = false,
      support_paste_from_clipboard = true, -- 支持剪贴板粘贴
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
    instructions_file = "avante.md", -- 项目根目录的指令文件

    -- 输入提供程序配置
    input = {
      provider = "dressing", -- 使用 dressing.nvim 提供增强的输入 UI
      provider_opts = {},
    },

    -- 文件选择器配置
    selector = {
      provider = "telescope", -- native | fzf_lua | mini_pick | snacks | telescope
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
    {
      "<leader>am",
      function()
        require("avante.api").switch_provider()
      end,
      desc = "切换 AI 模型",
    },
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
