-- blink.cmp configuration with avante support
return {
  "saghen/blink.cmp",
  dependencies = {
    "Kaiser-Yang/blink-cmp-avante",
    "L3MON4D3/LuaSnip",
  },
  opts = {
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
    },
  },
}