-- Zig 工具模块初始化
-- 导出所有子模块

local M = {}

-- 导出子模块
M.terminal = require("dirac.zig.terminal")
M.runner = require("dirac.zig.runner")
M.template = require("dirac.zig.template")

return M
