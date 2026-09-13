-- Neotree 文件管理器配置
-- 扩展 LazyVim 默认配置，添加 CodeCompanion 集成功能

return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)
    -- 扩展 filesystem 配置
    if not opts.filesystem then
      opts.filesystem = {}
    end

    -- 添加 CodeCompanion 集成命令
    if not opts.filesystem.commands then
      opts.filesystem.commands = {}
    end

    -- 把光标所在文件加入 CodeCompanion 对话上下文
    -- 实现上复用内置 /file slash command 的 output()，等价于在对话里敲 `/file` 选中该文件。
    -- 依赖 CodeCompanion 内部模块路径，故整体 pcall 兜底：上游重构时只失效这一个映射，不影响 neo-tree。
    opts.filesystem.commands.codecompanion_add_file = function(state)
      local node = state.tree:get_node()
      if node.type ~= "file" then
        return vim.notify("只能添加文件", vim.log.levels.WARN)
      end
      local path = node:get_id()

      local ok, err = pcall(function()
        local cc = require("codecompanion")
        local chat = cc.last_chat() or cc.chat()
        if not chat then
          error("无法创建 CodeCompanion 对话缓冲区")
        end

        local slash_config = require("codecompanion.config").interactions.chat.slash_commands["file"]
        require("codecompanion.interactions.shared.slash_commands.file")
          .new({ Chat = chat, config = slash_config, context = {}, opts = slash_config.opts })
          :output({ path = path, relative_path = vim.fn.fnamemodify(path, ":.") })

        chat.ui:open()
      end)

      if not ok then
        return vim.notify("添加到 CodeCompanion 失败: " .. tostring(err), vim.log.levels.ERROR)
      end
      vim.notify("已添加到 CodeCompanion: " .. vim.fn.fnamemodify(path, ":."), vim.log.levels.INFO)
    end

    -- 扩展窗口映射
    if not opts.window then
      opts.window = {}
    end
    if not opts.window.mappings then
      opts.window.mappings = {}
    end

    -- 添加快捷键映射
    opts.window.mappings["oa"] = {
      "codecompanion_add_file",
      desc = "添加文件到 CodeCompanion 对话",
    }

    return opts
  end,
}
