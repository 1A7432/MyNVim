-- 使用 LazyVim 默认的 treesitter 配置，避免兼容性问题
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "lua",
        "java",
        "rust",
        "javascript",
        "typescript",
        "python",
        "markdown",
        "markdown_inline",
        "html",
        "yaml",
        "latex", -- 用于数学公式渲染
      },
    },
  },
}
