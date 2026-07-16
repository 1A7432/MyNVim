-- 会话管理：已整体禁用（从不使用会话保存/恢复）
-- 关闭 LazyVim 默认自带的 persistence.nvim，连带原来的 <leader>q* 会话键、
-- 自动恢复、状态栏会话图标一并去除。
-- 如果哪天又想用会话：把下面这行删掉即可恢复 LazyVim 默认的 persistence。
return {
  { "folke/persistence.nvim", enabled = false },
}
