-- neocodeium - 免费快速的 AI 代码补全（基于 Windsurf）
-- 与 blink.cmp 协同工作
return {
  "monkoose/neocodeium",
  event = "VeryLazy",
  config = function()
    local neocodeium = require("neocodeium")

    -- 配置 neocodeium
    neocodeium.setup({
      enabled = false, -- 2026-07-14 停用:后端已随 Devin 收购晃动(2026-06 认证断过一次,见 upstream issues);补全改走 avante auto_suggestions + xai grok-build-0.1,本插件留作备胎
      manual = false,
      debounce = true,
      show_label = true,

      -- 在 avante 的对话/输入 buffer 里禁用 ghost text,避免与 avante 冲突
      filetypes = {
        Avante = false,
        AvanteInput = false,
        AvantePromptInput = false,
        AvanteSelectedFiles = false,
      },

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
