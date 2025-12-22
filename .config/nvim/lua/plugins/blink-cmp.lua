-- blink.cmp configuration with avante support
return {
  "saghen/blink.cmp",
  dependencies = {
    "Kaiser-Yang/blink-cmp-avante",
    "L3MON4D3/LuaSnip",
  },
  opts = {
    -- 关键的键映射配置
    keymap = {
      -- 禁用 Ctrl-Y（留给 neocodeium 使用）
      ['<C-y>'] = {},

      -- 补全菜单导航
      ['<Tab>'] = {
        function(cmp)
          if cmp.is_visible() then
            -- 如果补全菜单可见，选择下一个项目
            cmp.select_next()
          else
            -- 否则，尝试展开代码片段或使用默认行为
            cmp.snippet_forward()
          end
        end,
        'snippet_forward', -- 如果没有代码片段，使用默认的 snippet_forward
      },
      ['<S-Tab>'] = {
        function(cmp)
          if cmp.is_visible() then
            -- 如果补全菜单可见，选择上一个项目
            cmp.select_prev()
          else
            -- 否则，尝试回退代码片段
            cmp.snippet_backward()
          end
        end,
        'snippet_backward', -- 如果没有代码片段，使用默认的 snippet_backward
      },
      -- 确认选择
      ['<CR>'] = { 'accept', 'fallback' },
      -- 关闭补全菜单
      ['<C-e>'] = { 'hide', 'fallback' },
      -- 手动触发补全
      ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
      -- 向下滚动文档
      ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
      -- 向上滚动文档
      ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
      -- 向下导航（替代 Ctrl-n）
      ['<Down>'] = { 'select_next', 'fallback' },
      -- 向上导航（替代 Ctrl-p）
      ['<Up>'] = { 'select_prev', 'fallback' },
    },
    sources = {
      default = { "avante", "lsp", "path", "snippets", "buffer" },
      providers = {
        avante = {
          module = "blink-cmp-avante",
          name = "Avante",
          opts = {
            command = {
              get_kind_name = function(_)
                return "AvanteCmd"
              end,
            },
            mention = {
              get_kind_name = function(_)
                return "AvanteMention"
              end,
            },
            shortcut = {
              get_kind_name = function(_)
                return "AvanteShortcut"
              end,
            },
          },
        },
      },
    },
    snippets = {
      preset = "luasnip",
      expand = function(snippet)
        require('luasnip').lsp_expand(snippet)
      end,
      active = function(filter)
        if filter then
          return require('luasnip').jumpable(1)
        else
          return require('luasnip').in_snippet()
        end
      end,
      jump = function(direction)
        require('luasnip').jump(direction)
      end,
    },
  },
}
