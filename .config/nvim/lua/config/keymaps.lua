-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- 设置 leader 键为空格
vim.g.mapleader = " "

-- 设置所有操作都使用系统剪贴板
-- vim.opt.clipboard:append('unnamedplus')

-- 在 macOS 上设置按键映射
if vim.fn.has("mac") == 1 then
  -- 在普通模式下的映射
  vim.keymap.set("n", "y", '"+y', { noremap = true })
  vim.keymap.set("n", "Y", '"+Y', { noremap = true })
  vim.keymap.set("n", "p", '"+p', { noremap = true })
  vim.keymap.set("n", "P", '"+P', { noremap = true })

  -- 在可视模式下的映射
  vim.keymap.set("v", "y", '"+y', { noremap = true })
  vim.keymap.set("v", "Y", '"+Y', { noremap = true })
  vim.keymap.set("v", "p", '"+p', { noremap = true })
  vim.keymap.set("v", "P", '"+P', { noremap = true })

  -- 全选映射
  vim.keymap.set("n", "<C-a>", "ggVG", { noremap = true })
  vim.keymap.set("i", "<C-a>", "<Esc>ggVG", { noremap = true })
  vim.keymap.set("v", "<C-a>", "<Esc>ggVG", { noremap = true })
end

-- 会话管理键位映射
local function session_keymaps()
  -- 使用 <leader>s 前缀的会话管理命令
  vim.keymap.set("n", "<leader>ss", function()
    require("persistence").save()
  end, { desc = "保存当前会话" })

  vim.keymap.set("n", "<leader>sr", function()
    require("persistence").load()
  end, { desc = "恢复会话" })

  vim.keymap.set("n", "<leader>sl", function()
    require("persistence").load({ last = true })
  end, { desc = "恢复最近会话" })

  vim.keymap.set("n", "<leader>sd", function()
    require("persistence").stop()
  end, { desc = "停止会话保存" })

  -- 手动创建新会话
  vim.keymap.set("n", "<leader>sc", function()
    local session_dir = vim.fn.stdpath("state") .. "/sessions/"
    local cwd = vim.fn.getcwd()
    local session_name = cwd:gsub("/", "%%") .. ".vim"
    local session_path = session_dir .. session_name
    
    vim.fn.mkdir(session_dir, "p")
    vim.cmd("mksession! " .. session_path)
    vim.notify("会话已保存: " .. session_name, vim.log.levels.INFO)
  end, { desc = "手动保存会话" })

  -- 显示当前会话信息
  vim.keymap.set("n", "<leader>si", function()
    local session_dir = vim.fn.stdpath("state") .. "/sessions/"
    local cwd = vim.fn.getcwd()
    local session_name = cwd:gsub("/", "%%") .. ".vim"
    local session_path = session_dir .. session_name
    
    if vim.fn.filereadable(session_path) == 1 then
      local stats = vim.fn.getftime(session_path)
      local time_str = os.date("%Y-%m-%d %H:%M:%S", stats)
      vim.notify("当前会话: " .. session_name .. "\n最后保存: " .. time_str, vim.log.levels.INFO)
    else
      vim.notify("当前目录没有保存的会话", vim.log.levels.WARN)
    end
  end, { desc = "显示会话信息" })
end

session_keymaps()