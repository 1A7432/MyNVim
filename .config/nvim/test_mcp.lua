-- 测试 avante.nvim 中的 MCP 工具
print("=== 测试 MCP 工具集成 ===")

-- 1. 检查 mcphub 加载状态
local mcphub_ok, mcphub = pcall(require, 'mcphub')
print("mcphub 加载状态:", mcphub_ok)

if mcphub_ok then
    print("mcphub 版本信息:")
    local state = mcphub.get_state()
    if state then
        print("  - 设置状态:", state.setup_state)
        print("  - 服务器状态:", state.server_state.state)
        print("  - 配置的服务器:")
        for name, config in pairs(state.config.servers or {}) do
            print("    *", name, "->", config.command, table.concat(config.args or {}, " "))
        end
    end
end

-- 2. 检查 avante 加载状态
local avante_ok, avante = pcall(require, 'avante')
print("avante 加载状态:", avante_ok)

if avante_ok then
    print("avante 配置:")
    local config = require('avante.config').get_config()
    if config then
        print("  - Provider:", config.provider)
        print("  - MCP 集成: 通过 mcphub.nvim")
    end
end

-- 3. 检查是否有可用的 MCP 工具
print("=== 检查可用工具 ===")
if mcphub_ok then
    -- 等待一下让 mcphub 连接
    vim.defer_fn(function()
        local updated_state = mcphub.get_state()
        print("更新后的服务器状态:", updated_state.server_state.state)
        
        if updated_state.server_state.servers then
            print("已连接的服务器:")
            for name, server in pairs(updated_state.server_state.servers) do
                print("  - " .. name .. ": " .. (server.status or "unknown"))
            end
        end
    end, 2000)
end

print("=== 测试完成 ===")
print("提示: 你现在可以在 avante 对话中尝试使用以下工具:")
print("  - 搜索: 使用 kimi-search")
print("  - 获取网页内容: 使用 fetch")
print("  - 查询文档: 使用 context7")