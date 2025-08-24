return {
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      -- 在 LazyVim 默认配置基础上添加代码检查工具
      opts.settings = vim.tbl_deep_extend("force", opts.settings or {}, {
        java = {
          checkstyle = {
            enabled = true,
            configuration = vim.fn.getcwd() .. "/checkstyle.xml",
          },
          pmd = {
            enabled = true,
            rulesets = { vim.fn.getcwd() .. "/pmd_ruleset.xml" },
          },
          spotbugs = {
            enabled = true,
          },
        },
      })
      return opts
    end,
  },
}
