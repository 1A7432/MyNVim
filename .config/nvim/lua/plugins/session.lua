-- 会话管理配置
-- 使用 persistence.nvim 实现自动保存和恢复会话
-- 确保窗口布局、尺寸和位置都能被正确恢复

return {
  -- 自动会话保存和恢复
  {
    "folke/persistence.nvim",
    event = "BufReadPre", -- 提前加载以确保正确恢复
    opts = {
      -- 会话文件保存目录
      dir = vim.fn.stdpath("state") .. "/sessions/",
      need = 1,
      branch = true,
    },
    -- 自定义键映射
    keys = {
      {
        "<leader>qs",
        function()
          require("persistence").load()
        end,
        desc = "恢复会话",
      },
      {
        "<leader>ql",
        function()
          require("persistence").load({ last = true })
        end,
        desc = "恢复最近会话",
      },
      {
        "<leader>qd",
        function()
          require("persistence").stop()
        end,
        desc = "停止当前会话保存",
      },
    },
    config = function(_, opts)
      require("persistence").setup(opts)

      -- 确保会话选项包含窗口布局相关信息
      vim.opt.sessionoptions = {
        "buffers",
        "curdir",
        "folds",
        "globals",
        "help",
        "tabpages",
        "terminal",
        "winpos",
        "winsize",
      }

      -- persistence.nvim 通过 User 事件提供保存前钩子。
      vim.api.nvim_create_autocmd("User", {
        group = vim.api.nvim_create_augroup("PersistenceHooks", { clear = true }),
        pattern = "PersistenceSavePre",
        callback = function()
          vim.cmd("silent! Neotree close")
          vim.cmd("silent! cclose")
          vim.cmd("silent! lclose")
        end,
      })
    end,
  },

  -- 手动会话管理插件（可选，提供更多控制）
  {
    "rmagatti/auto-session",
    enabled = false, -- 默认禁用，可与persistence.nvim二选一
    dependencies = {
      "ibhagwan/fzf-lua", -- 可选，用于会话选择
    },
    opts = {
      log_level = "error",
      auto_session_enable_last_session = false,
      auto_session_root_dir = vim.fn.stdpath("data") .. "/sessions/",
      auto_session_enabled = true,
      auto_save_enabled = true,
      auto_restore_enabled = true,
      auto_session_suppress_dirs = { "/", "/tmp", "/Users" },
      session_lens = {
        buftypes_to_ignore = {},
        load_on_setup = true,
        theme_conf = { border = true },
        previewer = false,
        mappings = {
          delete_session = { "i", "<C-D>" },
          alternate_session = { "i", "<C-S>" },
          copy_session = { "i", "<C-O>" },
        },
      },
    },
    keys = {
      { "<leader>ss", "<cmd>SessionSave<cr>", desc = "保存会话" },
      { "<leader>sl", "<cmd>SessionLoad<cr>", desc = "加载会话" },
      { "<leader>sd", "<cmd>SessionDelete<cr>", desc = "删除会话" },
      { "<leader>sL", "<cmd>SessionSearch<cr>", desc = "搜索会话" },
    },
  },

  -- 会话状态显示
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    opts = function(_, opts)
      -- 在状态栏显示当前会话状态
      if not opts.sections then
        opts.sections = {}
      end
      if not opts.sections.lualine_x then
        opts.sections.lualine_x = {}
      end
      table.insert(opts.sections.lualine_x, {
        function()
          local session = vim.fn.getcwd()
          local session_file = vim.fn.stdpath("state") .. "/sessions/" .. session:gsub("/", "%%") .. ".vim"
          if vim.fn.filereadable(session_file) == 1 then
            return "󰆓"
          end
          return ""
        end,
        color = { fg = "#98be65" },
      })
    end,
  },
}
