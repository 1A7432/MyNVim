-- 调整 Markdown 语法检查设置
return {
  -- 如果您想完全禁用 markdownlint
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        -- 注释掉下一行可以完全禁用 markdown 的 lint
        -- markdown = {},
        
        -- 或者保留但使用更宽松的配置
        markdown = { "markdownlint-cli2" },
      },
      linters = {
        ["markdownlint-cli2"] = {
          args = {
            "--config",
            vim.fn.stdpath("config") .. "/.markdownlint.yaml",
            "--",
          },
        },
      },
    },
  },
  
  -- 调整诊断显示
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- 降低 markdownlint 诊断的严重程度
      vim.diagnostic.config({
        virtual_text = {
          source = "if_many",
          severity = { min = vim.diagnostic.severity.WARN },
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })
      
      return opts
    end,
  },
}
