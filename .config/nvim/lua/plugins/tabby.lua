return {
  'nanozuki/tabby.nvim',
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    require('dirac.ui.tabby-config')
    vim.o.showtabline = 2
    -- sessionoptions 将由 session.lua 统一配置
    -- vim.opt.sessionoptions = 'curdir,folds,globals,help,tabpages,terminal,winsize'
  end
}
