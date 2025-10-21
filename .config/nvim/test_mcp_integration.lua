-- 测试 avante.nvim 与 MCP 的完整集成
print("=== 测试 avante.nvim + MCP 集成 ===")

-- 1. 检查 mcphub 状态
local mcphub = require('mcphub')
local state = mcphub.get_state()
print("1. MCP Hub 状态:")
print("   - 设置状态:", state.setup_state)
print("   - 服务器状态:", state.server_state.state)

-- 2. 检查已连接的 MCP 服务器
if state.server_state.servers then
    print("   - 已连接的服务器:")
    local count = 0
    for id, server in pairs(state.server_state.servers) do
        count = count + 1
        print("     " .. count .. ".", server.name or ("server-" .. id), "- 状态:", server.status or "unknown")
    end
else
    print("   - 服务器列表: 空")
end

-- 3. 检查 MCP 工具注册状态
local mcphub_ext = require('mcphub.extensions.avante')
local tools = {mcphub_ext.mcp_tool()}
print("2. MCP 工具注册:")
print("   - 工具数量:", #tools)
for _, tool in ipairs(tools) do
    print("     - " .. tool.name .. ": " .. (tool.description or "无描述"))
end

-- 4. 检查斜杠命令
print("3. MCP 斜杠命令:")
local hub = mcphub.get_hub_instance()
if hub then
    local prompts = hub:get_prompts()
    print("   - 可用提示数量:", #prompts)
    for _, prompt in ipairs(prompts) do
        local cmd_name = "mcp:" .. prompt.server_name .. ":" .. prompt.name
        print("     /" .. cmd_name .. " - " .. (prompt.description or ""))
    end
else
    print("   - Hub 实例未初始化")
end

print("\n=== 使用说明 ===")
print("现在你可以在 avante 中使用：")
print("1. MCP 工具会自动被 AI 调用（无需手动指定）")
print("2. 使用斜杠命令，例如：")
if hub then
    local prompts = hub:get_prompts()
    for _, prompt in ipairs(prompts) do
        local cmd_name = "mcp:" .. prompt.server_name .. ":" .. prompt.name
        print("   /" .. cmd_name)
        break -- 只显示第一个例子
    end
end
print("3. 直接询问需要搜索或文档的问题，AI 会自动选择合适的工具")

print("\n=== 测试完成 ===")