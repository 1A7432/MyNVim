-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- 会话管理自动命令
local session_group = vim.api.nvim_create_augroup("SessionManagement", { clear = true })

-- 在进入Vim时恢复会话
vim.api.nvim_create_autocmd("VimEnter", {
  group = session_group,
  callback = function()
    -- 只有在没有传入文件参数时才恢复会话
    if vim.fn.argc() == 0 then
      require("persistence").load()
    end
  end,
  nested = true,
})

-- 在离开Vim时保存会话
vim.api.nvim_create_autocmd("VimLeavePre", {
  group = session_group,
  callback = function()
    require("persistence").save()
  end,
})

-- 当切换目录时创建新的会话
vim.api.nvim_create_autocmd("DirChanged", {
  group = session_group,
  callback = function()
    require("persistence").save()
  end,
})
