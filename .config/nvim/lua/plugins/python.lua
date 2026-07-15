return {
  -- 明确启用 Pyright；虚拟环境统一交给 LazyVim 自带的 venv-selector.nvim。
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          enabled = true,
        },
      },
    },
  },
}
