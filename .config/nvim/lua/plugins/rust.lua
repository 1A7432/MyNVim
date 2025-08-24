return {
  {
    "mrcjkb/rustaceanvim",
    opts = {
      server = {
        default_settings = {
          ["rust-analyzer"] = {
            checkOnSave = {
              command = "clippy",
              extraArgs = { "--all", "--", "-W", "clippy::all" },
            },
            diagnostics = {
              enable = true,
            },
            rustfmt = {
              extraArgs = { "+nightly" },
            },
          },
        },
        on_attach = function(client, bufnr)
          -- 默认快捷键
          vim.keymap.set("n", "<leader>cR", function() vim.cmd.RustLsp("codeAction") end,
            { desc = "Code Action", buffer = bufnr })
          vim.keymap.set("n", "<leader>dr", function() vim.cmd.RustLsp("debuggables") end,
            { desc = "Rust Debuggables", buffer = bufnr })

          -- 格式化快捷键
          vim.keymap.set("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end,
            { desc = "Format Document", buffer = bufnr })

          -- 组织导入 - 对于 Rust，通常通过 code action 来实现
          vim.keymap.set("n", "<leader>co", function()
            vim.lsp.buf.code_action({
              context = {
                only = { "source.organizeImports" },
                diagnostics = {} -- 提供空的 diagnostics 数组
              }
            })
          end, { desc = "Organize Imports", buffer = bufnr })
        end,
      },
    },
  },
}
