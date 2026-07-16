-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- 设置 leader 键为空格
vim.g.mapleader = " "

-- 设置所有操作都使用系统剪贴板
-- vim.opt.clipboard:append('unnamedplus')

-- 在 macOS 上设置按键映射
if vim.fn.has("mac") == 1 then
  -- 由于已设置 clipboard=unnamedplus，y/p 默认就是系统剪贴板
  -- 避免重复映射导致的循环调用，改为显式的额外快捷键

  -- 全选映射
  vim.keymap.set("n", "<C-a>", "ggVG", { noremap = true })
  vim.keymap.set("i", "<C-a>", "<Esc>ggVG", { noremap = true })
  vim.keymap.set("v", "<C-a>", "<Esc>ggVG", { noremap = true })
end
