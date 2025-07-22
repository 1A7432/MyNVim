return{
    {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "java", "rust", "javascript", "typescript", "python" }, -- 根据需要添加语言
        highlight = { enable = true },
      })
    end,
  }
}