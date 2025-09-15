-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- 系统剪贴板设置
vim.opt.clipboard = "unnamedplus" -- 使用系统剪贴板作为默认寄存器

-- 显式配置 clipboard provider 以避免缓存和循环问题
if vim.fn.has("mac") == 1 then
  vim.g.clipboard = {
    name = "pbcopy",
    copy = {
      ["+"] = "pbcopy",
      ["*"] = "pbcopy",
    },
    paste = {
      ["+"] = "pbpaste",
      ["*"] = "pbpaste",
    },
    cache_enabled = 0, -- 禁用缓存以避免重复读取问题
  }
end
