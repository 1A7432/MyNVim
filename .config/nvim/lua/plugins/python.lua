return {
  -- 安装并配置 nvim-python-venv（从 GitHub 仓库）
  {
    "1A7432/nvim-python-venv",
    ft = "python",
    config = function()
      require("nvim-python-venv").setup()
    end,
  },

  -- LSP 配置，保留原有 pyright 与 ruff 设置
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        basedpyright = {
          settings = {
            python = {
              analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
              },
            },
          },
        },
        pyright = false,
        ruff = {
          cmd_env = { RUFF_TRACE = "messages" },
          init_options = {
            settings = {
              logLevel = "debug",
            },
          },
          keys = {
            -- 使用 LazyVim 内置的方法，避免类型错误
            { "<leader>co", LazyVim.lsp.action["source.organizeImports"],        desc = "Organize Imports" },
            { "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, desc = "Format Document" },
            -- 【新增】这个是全部修复，修复所有 Ruff 问题
            {
              "<leader>cF",
              function()
                vim.lsp.buf.code_action({
                  context = {
                    only = { "source.fixAll" },
                    diagnostics = {},
                  },
                  apply = true, -- 自动应用修复
                })
              end,
              desc = "Fix All (Ruff)",
            },
          },
        },
      },
    },
  },
}
