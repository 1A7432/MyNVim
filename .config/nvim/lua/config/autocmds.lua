-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

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

-- 透明背景设置
local transparency_group = vim.api.nvim_create_augroup("TransparentBackground", { clear = true })

-- 在主题加载后强制应用透明背景
vim.api.nvim_create_autocmd("ColorScheme", {
  group = transparency_group,
  callback = function()
    -- 主窗口透明
    vim.api.nvim_set_hl(0, "Normal", { bg = "NONE", ctermbg = "NONE" })
    vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE", ctermbg = "NONE" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE", ctermbg = "NONE" })
    vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE", ctermbg = "NONE" })

    -- 侧边栏透明 (NeoTree)
    vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "NONE", ctermbg = "NONE" })
    vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "NONE", ctermbg = "NONE" })

    -- 符号列透明
    vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE", ctermbg = "NONE" })
    vim.api.nvim_set_hl(0, "LineNr", { bg = "NONE", ctermbg = "NONE" })
    vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "NONE", ctermbg = "NONE" })
    vim.api.nvim_set_hl(0, "FoldColumn", { bg = "NONE", ctermbg = "NONE" })

    -- Git 符号透明
    vim.api.nvim_set_hl(0, "GitSignsAdd", { bg = "NONE", ctermbg = "NONE" })
    vim.api.nvim_set_hl(0, "GitSignsChange", { bg = "NONE", ctermbg = "NONE" })
    vim.api.nvim_set_hl(0, "GitSignsDelete", { bg = "NONE", ctermbg = "NONE" })

    -- Telescope 透明
    vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "NONE", ctermbg = "NONE" })
    vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "NONE", ctermbg = "NONE" })

    -- 通知窗口透明 (如果你想要的话)
    vim.api.nvim_set_hl(0, "NotifyBackground", { bg = "NONE", ctermbg = "NONE" })
  end,
})
