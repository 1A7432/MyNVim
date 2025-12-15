-- C++ 工具模块初始化
-- 导出所有子模块

local M = {}

-- 导出子模块
M.terminal = require("dirac.cpp.terminal")
M.runner = require("dirac.cpp.runner")
M.competitive = require("dirac.cpp.competitive")

return M
