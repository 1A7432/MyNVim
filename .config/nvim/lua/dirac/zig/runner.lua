-- Zig 编译和运行模块
-- 支持单文件编译、zig build 项目、测试等功能

local M = {}
local terminal = require("dirac.zig.terminal")

-- 配置选项
M.config = {
  -- 编译器
  compiler = "zig",
  -- 优化模式: Debug, ReleaseSafe, ReleaseFast, ReleaseSmall
  build_mode = "Debug",
  -- 额外的编译标志
  compile_flags = "",
}

-- ============================================================
-- zig build 项目支持
-- ============================================================

-- 查找项目根目录中的 build.zig
-- @return string|nil build.zig 路径，如果不存在则返回 nil
function M.find_build_zig()
  local cwd = vim.fn.getcwd()
  local build_zig = cwd .. "/build.zig"

  if vim.fn.filereadable(build_zig) == 1 then
    return build_zig
  end

  return nil
end

-- 检测当前项目是否使用 zig build
-- @return boolean
function M.has_build_zig()
  return M.find_build_zig() ~= nil
end

-- 运行 zig build 命令
-- @param target string 构建目标（可选）
-- @param extra_args string 额外参数（可选）
function M.zig_build(target, extra_args)
  if not M.has_build_zig() then
    vim.notify("当前目录没有找到 build.zig", vim.log.levels.WARN)
    return
  end

  target = target or ""
  extra_args = extra_args or ""

  local build_cmd = string.format("zig build %s %s", target, extra_args):gsub("%s+$", "")

  terminal.run_in_float(build_cmd, {
    title = "Zig Build" .. (target ~= "" and ": " .. target or ""),
  })
end

-- 运行 zig build 并执行
function M.zig_build_run()
  if not M.has_build_zig() then
    vim.notify("当前目录没有找到 build.zig", vim.log.levels.WARN)
    return
  end

  local build_cmd = "zig build run"

  terminal.run_in_float(build_cmd, {
    title = "Zig Build Run",
  })
end

-- 运行 zig build test
function M.zig_build_test()
  if not M.has_build_zig() then
    vim.notify("当前目录没有找到 build.zig", vim.log.levels.WARN)
    return
  end

  local test_cmd = "zig build test"

  terminal.run_in_float(test_cmd, {
    title = "Zig Build Test",
  })
end

-- 列出所有构建步骤
function M.zig_build_list()
  if not M.has_build_zig() then
    vim.notify("当前目录没有找到 build.zig", vim.log.levels.WARN)
    return
  end

  terminal.run_in_float("zig build --help", {
    title = "Zig Build Steps",
  })
end

-- ============================================================
-- 单文件编译支持
-- ============================================================

-- 编译单个 Zig 文件为可执行文件
-- @param file_path string 源文件路径
-- @param output_path string 输出文件路径（可选）
-- @param extra_flags string 额外的编译标志（可选）
-- @return string 编译命令
function M.compile_single_file(file_path, output_path, extra_flags)
  file_path = file_path or vim.fn.expand("%:p")
  output_path = output_path or vim.fn.expand("%:p:r")
  extra_flags = extra_flags or ""

  -- 构建编译命令
  local compile_cmd = string.format(
    "zig build-exe -O%s %s '%s' && mv %s '%s' 2>/dev/null || true",
    M.config.build_mode,
    extra_flags,
    file_path,
    vim.fn.expand("%:t:r"),
    output_path
  )

  return compile_cmd
end

-- 运行可执行文件
-- @param executable string 可执行文件路径
-- @param args string 命令行参数（可选）
function M.run_executable(executable, args)
  executable = executable or vim.fn.expand("%:p:r")
  args = args or ""

  -- 检查可执行文件是否存在
  if vim.fn.filereadable(executable) == 0 then
    vim.notify("可执行文件不存在: " .. executable, vim.log.levels.ERROR)
    return
  end

  -- 构建运行命令
  local run_cmd = string.format("'%s' %s", executable, args)

  -- 在浮动终端中运行
  terminal.run_in_float(run_cmd, {
    title = "运行: " .. vim.fn.fnamemodify(executable, ":t"),
  })
end

-- 编译并运行单个文件
-- @param extra_flags string 额外的编译标志（可选）
-- @param args string 运行时参数（可选）
function M.compile_and_run(extra_flags, args)
  -- 保存当前文件
  vim.cmd("silent! write")

  local file = vim.fn.expand("%:p")
  local exe = vim.fn.expand("%:p:r")

  -- 构建编译命令
  local compile_cmd = M.compile_single_file(file, exe, extra_flags)

  -- 构建运行命令
  local run_cmd = string.format("'%s' %s", exe, args or "")

  -- 组合命令：编译成功后运行
  local full_cmd = string.format(
    "%s && echo '\n=== 编译成功 ===\n' && %s",
    compile_cmd,
    run_cmd
  )

  -- 在浮动终端中执行
  terminal.run_in_float(full_cmd, {
    title = "编译并运行: " .. vim.fn.expand("%:t"),
  })
end

-- 快速编译（仅编译，不运行）
function M.quick_compile()
  -- 保存当前文件
  vim.cmd("silent! write")

  local file = vim.fn.expand("%:p")
  local exe = vim.fn.expand("%:p:r")

  local compile_cmd = M.compile_single_file(file, exe)

  terminal.run_in_float(compile_cmd, {
    title = "编译: " .. vim.fn.expand("%:t"),
  })
end

-- 使用 ReleaseFast 优化编译
function M.compile_optimized()
  -- 保存当前文件
  vim.cmd("silent! write")

  local file = vim.fn.expand("%:p")
  local exe = vim.fn.expand("%:p:r")

  -- 临时修改优化模式
  local old_mode = M.config.build_mode
  M.config.build_mode = "ReleaseFast"

  local compile_cmd = M.compile_single_file(file, exe)

  -- 恢复原优化模式
  M.config.build_mode = old_mode

  terminal.run_in_float(compile_cmd, {
    title = "优化编译: " .. vim.fn.expand("%:t"),
  })
end

-- 编译用于调试（Debug 模式）
function M.compile_for_debug()
  -- 保存当前文件
  vim.cmd("silent! write")

  local file = vim.fn.expand("%:p")
  local exe = vim.fn.expand("%:p:r")

  -- 临时修改优化模式
  local old_mode = M.config.build_mode
  M.config.build_mode = "Debug"

  local compile_cmd = M.compile_single_file(file, exe)

  -- 恢复原优化模式
  M.config.build_mode = old_mode

  terminal.run_in_float(compile_cmd, {
    title = "调试编译: " .. vim.fn.expand("%:t"),
  })

  return exe
end

-- ============================================================
-- 测试支持
-- ============================================================

-- 运行 zig test（测试当前文件）
function M.test_file()
  -- 保存当前文件
  vim.cmd("silent! write")

  local file = vim.fn.expand("%:p")

  local test_cmd = string.format("zig test '%s'", file)

  terminal.run_in_float(test_cmd, {
    title = "Zig Test: " .. vim.fn.expand("%:t"),
  })
end

-- 运行 zig test（所有测试）
function M.test_all()
  if M.has_build_zig() then
    -- 如果有 build.zig，使用 zig build test
    M.zig_build_test()
  else
    -- 否则测试当前文件
    M.test_file()
  end
end

-- ============================================================
-- 智能编译运行（自动检测项目类型）
-- ============================================================

-- 编译并运行（智能检测项目类型）
-- 如果有 build.zig 则使用 zig build run，否则使用单文件编译
function M.smart_build_and_run()
  if M.has_build_zig() then
    -- 使用 zig build run
    M.zig_build_run()
  else
    -- 单文件编译运行
    M.compile_and_run()
  end
end

-- ============================================================
-- 其他实用功能
-- ============================================================

-- 格式化当前文件
function M.format_file()
  vim.cmd("silent! write")
  local file = vim.fn.expand("%:p")

  local format_cmd = string.format("zig fmt '%s' && echo '格式化完成'", file)

  terminal.run_in_float(format_cmd, {
    title = "Zig Format",
  })

  -- 重新加载文件
  vim.schedule(function()
    vim.cmd("checktime")
  end)
end

-- 检查代码（不生成可执行文件）
function M.check_file()
  vim.cmd("silent! write")
  local file = vim.fn.expand("%:p")

  local check_cmd = string.format("zig ast-check '%s'", file)

  terminal.run_in_float(check_cmd, {
    title = "Zig AST Check: " .. vim.fn.expand("%:t"),
  })
end

-- 显示 Zig 版本
function M.show_version()
  terminal.run_in_float("zig version && zig env", {
    title = "Zig Version",
  })
end

return M
