-- neocodeium - 免费快速的 AI 代码补全（基于 Windsurf）
-- 与 blink.cmp 协同工作
return {
  "monkoose/neocodeium",
  event = "VeryLazy",
  config = function()
    local neocodeium = require("neocodeium")

    -- 配置 neocodeium
    neocodeium.setup({
      enabled = true,
      manual = false,
      debounce = true,
      show_label = true,

      -- 当 blink.cmp 菜单可见时隐藏建议
      filter = function()
        local has_blink, blink_cmp = pcall(require, "blink.cmp")
        if has_blink then
          return not blink_cmp.is_visible()
        end
        return true
      end,
    })

    -- 快捷键配置
    -- Ctrl-Y 现在可以用了（已从 blink.cmp 中禁用）

    vim.keymap.set("i", "<C-y>", function()
      require("neocodeium").accept()
    end, { desc = "Neocodeium: 接受建议" })

    vim.keymap.set("i", "<C-]>", function()
      require("neocodeium").cycle(1)
    end, { desc = "Neocodeium: 下一个建议" })

    vim.keymap.set("i", "<C-x>", function()
      require("neocodeium").clear()
    end, { desc = "Neocodeium: 清除建议" })
  end,
}
