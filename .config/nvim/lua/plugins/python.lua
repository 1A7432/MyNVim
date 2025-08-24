return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          -- 让 Mason 自动处理路径，不指定 cmd
          settings = {
            python = {
              analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
              }
            }
          }
        },
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
