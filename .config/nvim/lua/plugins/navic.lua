return {
  "SmiteshP/nvim-navic",
  dependencies = {
    "neovim/nvim-lspconfig",
  },
  config = function()
    local navic = require("nvim-navic")
    
    -- 获取调色板
    local function get_palette()
      local color_map = {
        black   = { index = 0, default = "#393b44" },
        white   = { index = 7, default = "#dfdfe0" },
      }
      
      local palette = {}
      for name, value in pairs(color_map) do
        local global_name = "terminal_color_" .. value.index
        palette[name] = vim.g[global_name] and vim.g[global_name] or value.default
      end
      
      return palette
    end
    
    local pal = get_palette()
    local status = vim.o.background == "dark" and 
        { fg = pal.black, bg = pal.white } or 
        { fg = pal.white, bg = pal.black }

    navic.setup({
      icons = {
        File          = "󰈙 ",
        Module        = " ",
        Namespace     = "󰌗 ",
        Package       = " ",
        Class         = "󰌗 ",
        Method        = "󰆧 ",
        Property      = " ",
        Field         = " ",
        Constructor   = " ",
        Enum         = "󰕘",
        Interface     = "󰕘",
        Function      = "󰊕 ",
        Variable      = "󰆧 ",
        Constant      = "󰏿 ",
        String        = "󰀬 ",
        Number        = "󰎠 ",
        Boolean       = "◩ ",
        Array         = "󰅪 ",
        Object        = "󰅩 ",
        Key           = "󰌋 ",
        Null          = "󰟢 ",
        EnumMember    = " ",
        Struct        = "󰌗 ",
        Event         = " ",
        Operator      = "󰆕 ",
        TypeParameter = "󰊄 ",
      },
      lsp = {
        auto_attach = true,
      },
      highlight = true,
      separator = " > ",
      depth_limit = 0,
      depth_limit_indicator = "..",
      safe_output = true,
      click = true,
      format_text = function(text)
        return text .. "%#NavicSuffix# %#NavicText#"
      end,
    })

    -- 设置 navic 的高亮组
    local colors = {
      ["NavicIconsFile"]          = { fg = "#2E3440" },
      ["NavicIconsModule"]        = { fg = "#3B4252" },
      ["NavicIconsNamespace"]     = { fg = "#434C5E" },
      ["NavicIconsPackage"]       = { fg = "#4C566A" },
      ["NavicIconsClass"]         = { fg = "#5E81AC" },
      ["NavicIconsMethod"]        = { fg = "#81A1C1" },
      ["NavicIconsProperty"]      = { fg = "#88C0D0" },
      ["NavicIconsField"]         = { fg = "#8FBCBB" },
      ["NavicIconsConstructor"]   = { fg = "#B48EAD" },
      ["NavicIconsEnum"]          = { fg = "#A3BE8C" },
      ["NavicIconsInterface"]     = { fg = "#5E81AC" },
      ["NavicIconsFunction"]      = { fg = "#81A1C1" },
      ["NavicIconsVariable"]      = { fg = "#434C5E" },
      ["NavicIconsConstant"]      = { fg = "#4C566A" },
      ["NavicIconsString"]        = { fg = "#A3BE8C" },
      ["NavicIconsNumber"]        = { fg = "#B48EAD" },
      ["NavicIconsBoolean"]       = { fg = "#81A1C1" },
      ["NavicIconsArray"]         = { fg = "#88C0D0" },
      ["NavicIconsObject"]        = { fg = "#5E81AC" },
      ["NavicIconsKey"]           = { fg = "#4C566A" },
      ["NavicIconsNull"]          = { fg = "#3B4252" },
      ["NavicIconsEnumMember"]    = { fg = "#8FBCBB" },
      ["NavicIconsStruct"]        = { fg = "#5E81AC" },
      ["NavicIconsEvent"]         = { fg = "#B48EAD" },
      ["NavicIconsOperator"]      = { fg = "#81A1C1" },
      ["NavicIconsTypeParameter"] = { fg = "#88C0D0" },
      ["NavicText"]               = { fg = "#2E3440" },
      ["NavicSeparator"]          = { fg = "#3B4252" },
    }

    -- 为每个高亮组设置背景色
    for group, color in pairs(colors) do
      vim.api.nvim_set_hl(0, group, {
        fg = color.fg,
        bg = pal.white,
        force = true,
      })
    end

    -- 添加一个专门用于末尾空格的高亮组
    vim.api.nvim_set_hl(0, "NavicSuffix", {
      fg = pal.black,
      bg = pal.white,
      force = true,
    })
  end,
}
