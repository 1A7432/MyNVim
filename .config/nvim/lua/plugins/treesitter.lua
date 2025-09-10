return{
    {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
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
          "latex"  -- 用于数学公式渲染
        },
        highlight = { enable = true },
      })
    end,
  }
}
