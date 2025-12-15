-- 编译和运行模块
-- 提供单文件编译、CMake 项目编译、Makefile 项目编译等功能

local M = {}
local terminal = require("dirac.cpp.terminal")

-- 配置选项
M.config = {
  -- 编译器选项
  compiler = "g++",
  c_compiler = "gcc",
  -- C++ 标准
  cpp_standard = "c++17",
  -- 编译标志
  compile_flags = "-Wall -Wextra -g",
  -- 优化级别
  optimization = "-O2",
  -- Makefile 配置
  makefile_name = "Makefile", -- 支持 Makefile 或 makefile
}

-- ============================================================
-- Makefile 项目支持
-- ============================================================

-- 查找项目根目录中的 Makefile
-- @return string|nil Makefile 路径，如果不存在则返回 nil
function M.find_makefile()
  local cwd = vim.fn.getcwd()

  -- 检查常见的 Makefile 名称
  local makefile_names = { "Makefile", "makefile", "GNUmakefile" }

  for _, name in ipairs(makefile_names) do
    local makefile_path = cwd .. "/" .. name
    if vim.fn.filereadable(makefile_path) == 1 then
      return makefile_path
    end
  end

  return nil
end

-- 检测当前项目是否使用 Makefile
-- @return boolean
function M.has_makefile()
  return M.find_makefile() ~= nil
end

-- 运行 make 命令
-- @param target string make 目标（可选，默认为空）
-- @param extra_args string 额外参数（可选）
function M.make_build(target, extra_args)
  if not M.has_makefile() then
    vim.notify("当前目录没有找到 Makefile", vim.log.levels.WARN)
    return
  end

  target = target or ""
  extra_args = extra_args or ""

  local make_cmd = string.format("make %s %s", target, extra_args):gsub("%s+$", "")

  terminal.run_in_float(make_cmd, {
    title = "Make" .. (target ~= "" and ": " .. target or ""),
  })
end

-- 运行 make clean
function M.make_clean()
  M.make_build("clean")
end

-- 运行 make test
function M.make_test()
  M.make_build("test")
end

-- 运行 make install
function M.make_install()
  M.make_build("install")
end

-- 运行 make run（如果 Makefile 中定义了 run 目标）
function M.make_run()
  M.make_build("run")
end

-- 编译并运行（智能检测项目类型）
-- 如果有 Makefile 则使用 make，否则使用单文件编译
function M.smart_build_and_run()
  if M.has_makefile() then
    -- 先编译，然后尝试运行
    local make_cmd = "make && (make run 2>/dev/null || echo '\n提示：Makefile 中没有定义 run 目标')"
    terminal.run_in_float(make_cmd, {
      title = "Make 编译并运行",
    })
  else
    -- 单文件编译运行
    M.compile_and_run()
  end
end

-- ============================================================
-- 单文件编译支持
-- ============================================================

-- 编译单个 C++ 文件
-- @param file_path string 源文件路径
-- @param output_path string 输出文件路径（可选）
-- @param extra_flags string 额外的编译标志（可选）
-- @return string 编译命令
function M.compile_single_file(file_path, output_path, extra_flags)
  file_path = file_path or vim.fn.expand("%:p")
  output_path = output_path or vim.fn.expand("%:p:r")
  extra_flags = extra_flags or ""

  -- 判断是 C 还是 C++
  local ext = vim.fn.expand("%:e")
  local compiler = (ext == "c" or ext == "h") and M.config.c_compiler or M.config.compiler
  local std_flag = (ext == "cpp" or ext == "cxx" or ext == "cc") and ("-std=" .. M.config.cpp_standard) or ""

  -- 构建编译命令
  local compile_cmd = string.format(
    "%s %s %s %s -o '%s' '%s'",
    compiler,
    std_flag,
    M.config.compile_flags,
    extra_flags,
    output_path,
    file_path
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

-- 使用优化标志编译（用于竞赛编程）
function M.compile_optimized()
  -- 保存当前文件
  vim.cmd("silent! write")

  local file = vim.fn.expand("%:p")
  local exe = vim.fn.expand("%:p:r")

  local compile_cmd = M.compile_single_file(file, exe, M.config.optimization)

  terminal.run_in_float(compile_cmd, {
    title = "优化编译: " .. vim.fn.expand("%:t"),
  })
end

-- 编译用于调试（-g -O0）
function M.compile_for_debug()
  -- 保存当前文件
  vim.cmd("silent! write")

  local file = vim.fn.expand("%:p")
  local exe = vim.fn.expand("%:p:r")

  local compile_cmd = M.compile_single_file(file, exe, "-g -O0")

  terminal.run_in_float(compile_cmd, {
    title = "调试编译: " .. vim.fn.expand("%:t"),
  })

  return exe
end

return M
