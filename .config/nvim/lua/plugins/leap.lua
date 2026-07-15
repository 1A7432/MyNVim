return {
  {
    "https://codeberg.org/andyg/leap.nvim.git",
    name = "leap.nvim",
    enabled = true,
    keys = {
      { "s", "<Plug>(leap-forward)", mode = { "n", "x", "o" }, desc = "向前 Leap" },
      { "S", "<Plug>(leap-backward)", mode = { "n", "x", "o" }, desc = "向后 Leap" },
      { "gs", "<Plug>(leap-from-window)", mode = { "n", "x", "o" }, desc = "跨窗口 Leap" },
    },
  },
}
