-- 终端管理模块
-- 提供浮动终端和分屏终端功能

local M = {}

-- 在浮动终端中运行命令
-- @param cmd string|string[] 要执行的命令
-- @param opts table 可选参数
--   - title string 终端标题
--   - width number 窗口宽度比例 (0-1)
--   - height number 窗口高度比例 (0-1)
--   - cwd string 工作目录
--   - env table 环境变量
function M.run_in_float(cmd, opts)
  opts = opts or {}

  -- 检查 snacks.nvim 是否可用
  local ok, snacks = pcall(require, "snacks")
  if not ok then
    vim.notify("snacks.nvim 未安装，无法创建浮动终端", vim.log.levels.ERROR)
    return
  end

  -- 配置浮动窗口
  local win_opts = {
    position = "float",
    width = opts.width or 0.8,
    height = opts.height or 0.8,
    border = "rounded",
    title = opts.title or "终端",
    title_pos = "center",
  }

  -- 执行命令
  snacks.terminal(cmd, {
    win = win_opts,
    cwd = opts.cwd,
    env = opts.env,
  })
end

-- 在分屏终端中运行命令
-- @param cmd string|string[] 要执行的命令
-- @param opts table 可选参数
--   - position string 位置: "bottom", "right", "left", "top"
--   - size number 窗口大小
function M.run_in_split(cmd, opts)
  opts = opts or {}

  local ok, snacks = pcall(require, "snacks")
  if not ok then
    vim.notify("snacks.nvim 未安装，无法创建分屏终端", vim.log.levels.ERROR)
    return
  end

  local win_opts = {
    position = opts.position or "bottom",
    size = opts.size or 15,
  }

  snacks.terminal(cmd, {
    win = win_opts,
    cwd = opts.cwd,
  })
end

-- 创建持久化终端（可以反复打开关闭）
-- @param cmd string|string[] 要执行的命令
-- @param id string 终端 ID，用于后续引用
function M.create_persistent(cmd, id, opts)
  opts = opts or {}

  local ok, snacks = pcall(require, "snacks")
  if not ok then
    vim.notify("snacks.nvim 未安装", vim.log.levels.ERROR)
    return
  end

  -- 使用 snacks 的终端功能创建持久化终端
  snacks.terminal(cmd, vim.tbl_extend("force", {
    win = {
      position = "float",
      width = 0.8,
      height = 0.8,
      border = "rounded",
      title = opts.title or ("终端 - " .. id),
    },
  }, opts))
end

return M
