-- Zig 模板管理模块
-- 提供快速创建 Zig 文件模板的功能

local M = {}

-- 模板配置
M.templates = {
  basic = {
    name = "基础模板",
    file = vim.fn.stdpath("config") .. "/templates/zig/basic.zig",
    description = "标准 Zig 程序模板",
  },
}

-- 读取模板内容
-- @param template_file string 模板文件路径
-- @return string 模板内容
local function read_template(template_file)
  local file = io.open(template_file, "r")
  if not file then
    vim.notify("无法读取模板文件: " .. template_file, vim.log.levels.ERROR)
    return nil
  end

  local content = file:read("*all")
  file:close()

  return content
end

-- 插入模板内容到当前缓冲区
-- @param template_key string 模板键名
function M.insert_template(template_key)
  local template = M.templates[template_key]

  if not template then
    vim.notify("模板不存在: " .. template_key, vim.log.levels.ERROR)
    return
  end

  -- 读取模板内容
  local content = read_template(template.file)
  if not content then
    return
  end

  -- 分割成行
  local lines = vim.split(content, "\n", { plain = true })

  -- 插入到当前缓冲区
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)

  -- 提示
  vim.notify("已插入模板: " .. template.name, vim.log.levels.INFO)
end

-- 使用 vim.ui.select 选择模板
function M.select_and_insert()
  -- 检查当前缓冲区是否为空
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local is_empty = #lines == 1 and lines[1] == ""

  if not is_empty then
    vim.ui.input({
      prompt = "当前文件不为空，是否覆盖？(y/N): ",
    }, function(input)
      if input and (input:lower() == "y" or input:lower() == "yes") then
        M.do_select()
      end
    end)
  else
    M.do_select()
  end
end

-- 执行选择
function M.do_select()
  -- 构建选择列表
  local items = {}
  local keys = {}

  for key, template in pairs(M.templates) do
    table.insert(items, string.format("%s - %s", template.name, template.description))
    table.insert(keys, key)
  end

  -- 使用 vim.ui.select 选择
  vim.ui.select(items, {
    prompt = "选择 Zig 模板:",
  }, function(_, idx)
    if idx then
      M.insert_template(keys[idx])
    end
  end)
end

-- 创建新文件并应用模板
-- @param filepath string 文件路径
-- @param template_key string 模板键名
function M.new_file_from_template(filepath, template_key)
  -- 创建新文件
  vim.cmd("edit " .. filepath)

  -- 插入模板
  M.insert_template(template_key)

  -- 保存
  vim.cmd("write")

  vim.notify("已创建文件: " .. filepath, vim.log.levels.INFO)
end

return M
