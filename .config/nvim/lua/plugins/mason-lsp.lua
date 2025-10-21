return {
  {
    "mason-org/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.ensure_installed = opts.ensure_installed or {}
      if not vim.tbl_contains(opts.ensure_installed, "basedpyright") then
        table.insert(opts.ensure_installed, "basedpyright")
      end
      return opts
    end,
  },
}
