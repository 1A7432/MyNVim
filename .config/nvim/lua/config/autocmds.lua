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

-- 输入法自动切换
local input_method_group = vim.api.nvim_create_augroup("InputMethodSwitch", { clear = true })

-- 存储进入插入模式前的输入法
local previous_im = "com.apple.keylayout.ABC"

-- 进入插入模式时记录当前输入法
vim.api.nvim_create_autocmd("InsertEnter", {
  group = input_method_group,
  callback = function()
    -- 获取当前输入法
    local handle = io.popen("im-select")
    if handle then
      local current_im = handle:read("*a"):gsub("%s+", "")
      handle:close()
      if current_im and current_im ~= "" then
        previous_im = current_im
      end
    end
  end,
})

-- 退出插入模式时切换到英文输入法
vim.api.nvim_create_autocmd("InsertLeave", {
  group = input_method_group,
  callback = function()
    -- 切换到英文输入法
    os.execute("im-select com.apple.keylayout.ABC")
  end,
})

-- 重新进入插入模式时恢复之前的输入法（可选）
-- 如果你希望重新进入插入模式时恢复之前的输入法，可以取消下面的注释
-- vim.api.nvim_create_autocmd("InsertEnter", {
--   group = input_method_group,
--   callback = function()
--     if previous_im and previous_im ~= "com.apple.keylayout.ABC" then
--       os.execute("im-select " .. previous_im)
--     end
--   end,
-- })
