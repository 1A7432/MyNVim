return {
    {
        "EdenEast/nightfox.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            options = {
                -- 启用透明背景
                transparent = true,
                -- 透明的终端背景
                terminal_colors = true,
                dim_inactive = false,
                styles = {
                    comments = "italic",
                    keywords = "bold",
                    types = "italic,bold",
                },
            },
            groups = {
                all = {
                    -- 确保所有背景都是透明的
                    Normal = { bg = "NONE" },
                    NormalNC = { bg = "NONE" },
                    NormalFloat = { bg = "NONE" },
                    FloatBorder = { bg = "NONE" },
                    -- 侧边栏透明
                    NeoTreeNormal = { bg = "NONE" },
                    NeoTreeNormalNC = { bg = "NONE" },
                    -- 状态栏保持主题颜色（可选，如果想要透明可以改为 NONE）
                    -- StatusLine = { bg = "NONE" },
                    -- 符号列透明
                    SignColumn = { bg = "NONE" },
                    -- 行号列透明
                    LineNr = { bg = "NONE" },
                    CursorLineNr = { bg = "NONE" },
                    -- 折叠列透明
                    FoldColumn = { bg = "NONE" },
                    -- Git 符号列透明
                    GitSignsAdd = { bg = "NONE" },
                    GitSignsChange = { bg = "NONE" },
                    GitSignsDelete = { bg = "NONE" },
                },
            },
        },
        config = function(_, opts)
            require("nightfox").setup(opts)
            vim.cmd("colorscheme carbonfox")
        end,
    }
}