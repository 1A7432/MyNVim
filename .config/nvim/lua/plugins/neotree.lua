-- Neotree 文件管理器配置
-- 扩展 LazyVim 默认配置，添加 Avante 集成功能

return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)
    -- 扩展 filesystem 配置
    if not opts.filesystem then
      opts.filesystem = {}
    end

    -- 添加 Avante 集成命令
    if not opts.filesystem.commands then
      opts.filesystem.commands = {}
    end

    -- Avante 文件选择功能
    opts.filesystem.commands.avante_add_files = function(state)
      local node = state.tree:get_node()
      local filepath = node:get_id()
      local relative_path = require('avante.utils').relative_path(filepath)

      local sidebar = require('avante').get()

      local open = sidebar:is_open()
      -- 确保 avante 侧边栏是打开的
      if not open then
        require('avante.api').ask()
        sidebar = require('avante').get()
      end

      sidebar.file_selector:add_selected_file(relative_path)

      -- 移除 neo tree 缓冲区（如果之前没有打开）
      if not open then
        sidebar.file_selector:remove_selected_file('neo-tree filesystem [1]')
      end

      -- 显示成功消息
      vim.notify("已添加到 Avante: " .. relative_path, vim.log.levels.INFO)
    end

    -- 扩展窗口映射
    if not opts.window then
      opts.window = {}
    end
    if not opts.window.mappings then
      opts.window.mappings = {}
    end

    -- 添加快捷键映射
    opts.window.mappings['oa'] = {
      'avante_add_files',
      desc = '添加到 Avante 选定文件'
    }

    return opts
  end,

}