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
    opts = function(_, opts)
      opts = opts or {}
      opts.servers = opts.servers or {}

      -- 默认使用 basedpyright，禁用 pyright
      opts.servers.basedpyright = vim.tbl_deep_extend("force", opts.servers.basedpyright or {}, {
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
      })
      opts.servers.pyright = false

      -- 保留 Ruff 设置
      opts.servers.ruff = vim.tbl_deep_extend("force", opts.servers.ruff or {}, {
        cmd_env = { RUFF_TRACE = "messages" },
        init_options = {
          settings = { logLevel = "debug" },
        },
        keys = {
          { "<leader>co", LazyVim.lsp.action["source.organizeImports"], desc = "Organize Imports" },
          { "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, desc = "Format Document" },
          {
            "<leader>cF",
            function()
              vim.lsp.buf.code_action({
                context = { only = { "source.fixAll" }, diagnostics = {} },
                apply = true,
              })
            end,
            desc = "Fix All (Ruff)",
          },
        },
      })

      -- 兜底：进入 Python buffer 时，若未附加 basedpyright，则自动启动
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "python",
        callback = function(args)
          local bufnr = args.buf
          for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
            if c.name == "basedpyright" then return end
          end
          pcall(vim.cmd, "LspStart basedpyright")
        end,
      })

      return opts
    end,
  },

}
