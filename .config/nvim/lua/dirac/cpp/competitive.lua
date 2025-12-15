-- 竞赛编程模块
-- 提供输入测试、输出比对、批量测试等功能

local M = {}
local terminal = require("dirac.cpp.terminal")
local runner = require("dirac.cpp.runner")

-- 配置选项
M.config = {
  input_file = "input.txt",
  output_file = "output.txt",
  expected_file = "expected.txt",
  compile_flags = "-std=c++17 -O2 -Wall -Wextra",
  time_limit = 2000, -- 毫秒
}

-- 编译并用输入文件测试
function M.test_with_input()
  -- 保存当前文件
  vim.cmd("silent! write")

  local file = vim.fn.expand("%:p")
  local exe = vim.fn.expand("%:p:r")
  local input = M.config.input_file
  local output = M.config.output_file

  -- 检查输入文件是否存在
  if vim.fn.filereadable(input) == 0 then
    vim.notify("输入文件不存在: " .. input, vim.log.levels.WARN)
    vim.notify("请先创建 input.txt 或使用 <leader>rpi 编辑输入", vim.log.levels.INFO)
    return
  end

  -- 编译命令
  local compile_cmd = string.format(
    "%s %s -o '%s' '%s'",
    runner.config.compiler,
    M.config.compile_flags,
    exe,
    file
  )

  -- 运行命令（重定向输入输出，并计时）
  local run_cmd = string.format(
    "time '%s' < '%s' > '%s' 2>&1 || echo '\n[退出码: $?]'",
    exe,
    input,
    output
  )

  -- 显示输出
  local show_output_cmd = string.format(
    "echo '\n=== 输出内容 ===\n' && cat '%s'",
    output
  )

  -- 组合命令
  local full_cmd = string.format(
    "%s && echo '\n=== 编译成功 ===\n' && %s && %s",
    compile_cmd,
    run_cmd,
    show_output_cmd
  )

  terminal.run_in_float(full_cmd, {
    title = "测试: " .. vim.fn.expand("%:t"),
  })
end

-- 比对输出与期望输出
function M.compare_output()
  local output = M.config.output_file
  local expected = M.config.expected_file

  -- 检查文件是否存在
  if vim.fn.filereadable(output) == 0 then
    vim.notify("输出文件不存在，请先运行测试", vim.log.levels.WARN)
    return
  end

  if vim.fn.filereadable(expected) == 0 then
    vim.notify("期望输出文件不存在: " .. expected, vim.log.levels.WARN)
    vim.notify("请使用 <leader>rpe 创建期望输出文件", vim.log.levels.INFO)
    return
  end

  -- 使用 diff 比对
  local diff_cmd = string.format([[
if diff -q '%s' '%s' > /dev/null 2>&1; then
  echo "✓ 测试通过！输出与期望一致"
  echo ""
  echo "=== 输出内容 ==="
  cat '%s'
else
  echo "✗ 测试失败！输出与期望不一致"
  echo ""
  echo "=== 差异对比（左：期望 | 右：实际）==="
  diff -y '%s' '%s' || true
  echo ""
  echo "=== 详细差异 ==="
  diff -u '%s' '%s' || true
fi
]],
    expected, output,
    output,
    expected, output,
    expected, output
  )

  terminal.run_in_float(diff_cmd, {
    title = "输出比对",
  })
end

-- 批量测试（测试多个输入文件）
function M.batch_test()
  -- 保存当前文件
  vim.cmd("silent! write")

  local file = vim.fn.expand("%:p")
  local exe = vim.fn.expand("%:p:r")

  -- 编译命令
  local compile_cmd = string.format(
    "%s %s -o '%s' '%s'",
    runner.config.compiler,
    M.config.compile_flags,
    exe,
    file
  )

  -- 查找所有测试文件
  local test_files = vim.fn.glob("input*.txt", false, true)

  if #test_files == 0 then
    vim.notify("没有找到测试文件 (input*.txt)", vim.log.levels.WARN)
    vim.notify("请创建 input1.txt, input2.txt 等测试文件", vim.log.levels.INFO)
    return
  end

  -- 构建批量测试脚本
  local script_lines = {
    "#!/bin/bash",
    "set -e",
    compile_cmd,
    "echo '=== 编译成功 ==='",
    "echo ''",
    "total=0",
    "passed=0",
  }

  for _, input_file in ipairs(test_files) do
    local test_num = input_file:match("input(%d+)%.txt") or ""
    local expected_file = "expected" .. test_num .. ".txt"
    local output_file = "output" .. test_num .. ".txt"

    table.insert(script_lines, string.format([[
echo "=== 测试 %s ==="
total=$((total + 1))
time '%s' < '%s' > '%s' 2>&1 || echo "[退出码: $?]"
if [ -f '%s' ]; then
  if diff -q '%s' '%s' > /dev/null 2>&1; then
    echo "✓ 通过"
    passed=$((passed + 1))
  else
    echo "✗ 失败 - 输出不匹配"
    echo "--- 差异 ---"
    diff -y '%s' '%s' | head -20 || true
  fi
else
  echo "✓ 运行完成（无期望输出文件）"
  echo "--- 输出 ---"
  cat '%s' | head -20
  passed=$((passed + 1))
fi
echo ""
]], test_num, exe, input_file, output_file, expected_file,
    expected_file, output_file, expected_file, output_file, output_file))
  end

  table.insert(script_lines, [[
echo "=== 测试统计 ==="
echo "通过: $passed / $total"
if [ $passed -eq $total ]; then
  echo "✓ 所有测试通过！"
  exit 0
else
  echo "✗ 部分测试失败"
  exit 1
fi
]])

  -- 写入临时脚本
  local script_path = "/tmp/nvim_cpp_batch_test.sh"
  vim.fn.writefile(script_lines, script_path)
  vim.fn.system("chmod +x " .. script_path)

  terminal.run_in_float(script_path, {
    title = string.format("批量测试 (%d 个)", #test_files),
  })
end

-- 快速运行（编译+运行+计时）
function M.quick_run()
  -- 保存当前文件
  vim.cmd("silent! write")

  local file = vim.fn.expand("%:p")
  local exe = vim.fn.expand("%:p:r")
  local input = M.config.input_file

  local has_input = vim.fn.filereadable(input) == 1

  -- 编译命令
  local compile_cmd = string.format(
    "%s %s -o '%s' '%s'",
    runner.config.compiler,
    M.config.compile_flags,
    exe,
    file
  )

  -- 运行命令
  local run_cmd
  if has_input then
    run_cmd = string.format("time '%s' < '%s' 2>&1", exe, input)
  else
    run_cmd = string.format("time '%s' 2>&1", exe)
  end

  local full_cmd = string.format(
    "%s && echo '\n=== 运行结果 ===\n' && %s",
    compile_cmd,
    run_cmd
  )

  terminal.run_in_float(full_cmd, {
    title = "快速运行" .. (has_input and " (使用 input.txt)" or ""),
  })
end

-- 创建竞赛编程模板
function M.create_template()
  -- 获取模板路径
  local template_path = vim.fn.stdpath("config") .. "/templates/cpp/competitive.cpp"

  -- 询问文件名
  local filename = vim.fn.input({
    prompt = "文件名（不含扩展名）: ",
    default = "solution",
  })

  if filename == "" then
    return
  end

  local cpp_file = filename .. ".cpp"
  local input_file = "input.txt"
  local expected_file = "expected.txt"

  -- 检查文件是否已存在
  if vim.fn.filereadable(cpp_file) == 1 then
    local choice = vim.fn.confirm(
      cpp_file .. " 已存在，是否覆盖？",
      "&Yes\n&No",
      2
    )
    if choice ~= 1 then
      return
    end
  end

  -- 读取模板内容
  local template_content
  if vim.fn.filereadable(template_path) == 1 then
    template_content = vim.fn.readfile(template_path)
  else
    -- 默认模板
    template_content = {
      "#include <iostream>",
      "#include <vector>",
      "#include <algorithm>",
      "#include <string>",
      "#include <cmath>",
      "using namespace std;",
      "",
      "#ifdef LOCAL",
      "#define debug(x) cerr << #x << \" = \" << (x) << endl",
      "#else",
      "#define debug(x)",
      "#endif",
      "",
      "void solve() {",
      "    // 你的代码",
      "    ",
      "}",
      "",
      "int main() {",
      "    ios_base::sync_with_stdio(false);",
      "    cin.tie(nullptr);",
      "    ",
      "    int t = 1;",
      "    // cin >> t;  // 多测试用例时取消注释",
      "    ",
      "    while (t--) {",
      "        solve();",
      "    }",
      "    ",
      "    return 0;",
      "}",
    }
  end

  -- 写入文件
  vim.fn.writefile(template_content, cpp_file)

  -- 创建空的输入和期望输出文件
  if vim.fn.filereadable(input_file) == 0 then
    vim.fn.writefile({}, input_file)
  end
  if vim.fn.filereadable(expected_file) == 0 then
    vim.fn.writefile({}, expected_file)
  end

  -- 打开 C++ 文件
  vim.cmd("edit " .. cpp_file)

  vim.notify(
    string.format("已创建: %s, %s, %s", cpp_file, input_file, expected_file),
    vim.log.levels.INFO
  )
end

-- 在分屏中编辑输入文件
function M.edit_input()
  local input = M.config.input_file

  -- 如果文件不存在，创建它
  if vim.fn.filereadable(input) == 0 then
    vim.fn.writefile({}, input)
  end

  vim.cmd("vsplit " .. input)
end

-- 在分屏中编辑期望输出文件
function M.edit_expected()
  local expected = M.config.expected_file

  -- 如果文件不存在，创建它
  if vim.fn.filereadable(expected) == 0 then
    vim.fn.writefile({}, expected)
  end

  vim.cmd("vsplit " .. expected)
end

-- 查看输出文件
function M.show_output()
  local output = M.config.output_file

  if vim.fn.filereadable(output) == 1 then
    vim.cmd("vsplit " .. output)
  else
    vim.notify("输出文件不存在，请先运行测试", vim.log.levels.WARN)
  end
end

return M
