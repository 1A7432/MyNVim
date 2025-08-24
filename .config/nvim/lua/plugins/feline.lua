return {
  'famiu/feline.nvim',
  dependencies = { 
    "EdenEast/nightfox.nvim",
    "SmiteshP/nvim-navic",
  },
  opts = {},
  config = function(_, opts)
    require('dirac.ui.feline-config')
  end
}
