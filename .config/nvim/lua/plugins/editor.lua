-- 编辑器相关插件配置
return {
  -- 禁用 telescope，完全使用 fzf-lua
  {
    "nvim-telescope/telescope.nvim",
    enabled = false,
  },

  -- 禁用 flash.nvim，使用更强大的 leap.nvim
  {
    "folke/flash.nvim",
    enabled = false,
  },

  -- 禁用 dressing.nvim，使用 snacks.nvim + fzf-lua 组合
  {
    "stevearc/dressing.nvim",
    enabled = false,
  },

  -- 确保 fzf-lua 作为默认搜索器
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "FzfLua",
    keys = {
      { "<leader><space>", "<cmd>FzfLua files<cr>", desc = "查找文件" },
      { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "查找文件" },
      { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "搜索内容" },
      { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "查找缓冲区" },
      { "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "帮助文档" },
      { "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "最近文件" },
      { "<leader>fc", "<cmd>FzfLua commands<cr>", desc = "命令" },
      { "<leader>fk", "<cmd>FzfLua keymaps<cr>", desc = "键映射" },
      { "<leader>fs", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "文档符号" },
      { "<leader>fS", "<cmd>FzfLua lsp_workspace_symbols<cr>", desc = "工作区符号" },
    },
    opts = {
      winopts = {
        border = "rounded",
        height = 0.8,
        width = 0.8,
      },
      files = {
        prompt = "Files❯ ",
        git_icons = false,
      },
      grep = {
        prompt = "Grep❯ ",
      },
      buffers = {
        prompt = "Buffers❯ ",
      },
    },
  },
}