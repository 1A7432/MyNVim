-- 覆盖 LazyVim 的 markdown 配置，启用更多渲染功能
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "codecompanion" }, -- 支持 CodeCompanion 对话缓冲区
    opts = {
      -- 支持的文件类型
      file_types = { "markdown", "codecompanion" },
      -- 启用渲染
      enabled = true,
      
      -- 代码块配置
      code = {
        enabled = true,
        sign = true,
        style = "full",
        width = "block",
        right_pad = 1,
        left_pad = 1,
        language_pad = 2,
        border = "thin",
        above = "▄",
        below = "▀",
        highlight = "RenderMarkdownCode",
        highlight_inline = "RenderMarkdownCodeInline",
      },
      
      -- 标题配置 - 恢复图标
      heading = {
        enabled = true,
        sign = true,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
        signs = { "󰫎 " },
        width = "full",
        border = true,
        border_prefix = false,
        above = "▃",
        below = "🬂",
        backgrounds = {
          "RenderMarkdownH1Bg",
          "RenderMarkdownH2Bg", 
          "RenderMarkdownH3Bg",
          "RenderMarkdownH4Bg",
          "RenderMarkdownH5Bg",
          "RenderMarkdownH6Bg",
        },
        foregrounds = {
          "RenderMarkdownH1",
          "RenderMarkdownH2",
          "RenderMarkdownH3",
          "RenderMarkdownH4",
          "RenderMarkdownH5",
          "RenderMarkdownH6",
        },
      },
      
      -- 复选框配置 - 启用
      checkbox = {
        enabled = true,
        unchecked = {
          icon = "󰄱 ",
          highlight = "RenderMarkdownUnchecked",
        },
        checked = {
          icon = "󰱒 ",
          highlight = "RenderMarkdownChecked",
        },
        custom = {
          todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
          important = { raw = "[!]", rendered = "󰅾 ", highlight = "DiagnosticWarn" },
          cancelled = { raw = "[~]", rendered = "󰰱 ", highlight = "DiagnosticError" },
        },
      },
      
      -- 列表项
      bullet = {
        enabled = true,
        icons = { "●", "○", "◆", "◇" },
        highlight = "RenderMarkdownBullet",
      },
      
      -- 引用块
      quote = {
        enabled = true,
        icon = "▌",
        highlight = "RenderMarkdownQuote",
      },
      
      -- 表格
      pipe_table = {
        enabled = true,
        preset = "round",
        alignment_indicator = "─",
        head = "RenderMarkdownTableHead",
      },
      
      -- Callout 配置
      callout = {
        note = { raw = "[!NOTE]", rendered = "󰋽 Note", highlight = "RenderMarkdownInfo" },
        tip = { raw = "[!TIP]", rendered = "󰌶 Tip", highlight = "RenderMarkdownSuccess" },
        important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownHint" },
        warning = { raw = "[!WARNING]", rendered = "󰀪 Warning", highlight = "RenderMarkdownWarn" },
        caution = { raw = "[!CAUTION]", rendered = "󰳦 Caution", highlight = "RenderMarkdownError" },
      },
      
      -- 链接
      link = {
        enabled = true,
        image = "󰥶 ",
        email = "󰇮 ",
        hyperlink = "󰌹 ",
        highlight = "RenderMarkdownLink",
      },
      
      -- LaTeX 配置 - 重要！
      latex = {
        enabled = true,
        converter = "latex2text",
        highlight = "RenderMarkdownMath",
        position = "above",
        top_pad = 0,
        bottom_pad = 0,
      },
      
      -- 窗口选项
      win_options = {
        conceallevel = {
          default = 3,
          rendered = 3,
        },
        concealcursor = {
          default = "",
          rendered = "",
        },
      },
    },
  },
}
