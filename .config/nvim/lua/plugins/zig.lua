-- Zig 开发配置
-- 支持 zig build 项目和单文件编译
-- 包含编译、运行、测试、调试等功能

return {
  -- zls (Zig Language Server) LSP 配置
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        zls = {
          settings = {
            zls = {
              enable_autofix = false,
              enable_snippets = true,
              warn_style = true,
              enable_build_on_save = false,
              build_on_save_step = "check",
              -- 使用 zig 安装的标准库路径
              zig_lib_path = vim.fn.system("zig env | jq -r .lib_dir"):gsub("\n", ""),
            },
          },
        },
      },
    },
  },

  -- which-key 快捷键提示（集成到 C/C++ 的 <leader>r 组）
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>r", group = "运行/编译", icon = "" },
        { "<leader>rc", group = "Zig Build / CMake", icon = "" },
        { "<leader>rd", group = "调试", icon = "" },
        { "<leader>rn", group = "新建/模板", icon = "" },
      },
    },
  },

  -- 自定义快捷键和自动命令
  {
    "LazyVim/LazyVim",
    opts = function()
      -- 加载 Zig 工具模块
      local zig_runner = require("dirac.zig.runner")
      local zig_template = require("dirac.zig.template")

      -- 设置快捷键（仅在 Zig 文件中生效，集成到 <leader>r 前缀）
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "zig",
        callback = function(ev)
          local bufnr = ev.buf
          local opts = { buffer = bufnr, silent = true }

          -- 自动保存包装函数
          local function with_save(func)
            return function()
              vim.cmd("silent! write")
              func()
            end
          end

          -- 编译运行快捷键（与 C/C++ 统一使用 <leader>r 前缀）
          vim.keymap.set("n", "<leader>rs", with_save(zig_runner.smart_build_and_run), vim.tbl_extend("force", opts, { desc = "智能编译运行" }))
          vim.keymap.set("n", "<leader>rf", with_save(zig_runner.compile_and_run), vim.tbl_extend("force", opts, { desc = "单文件编译运行" }))
          vim.keymap.set("n", "<leader>rb", with_save(zig_runner.quick_compile), vim.tbl_extend("force", opts, { desc = "快速编译" }))
          vim.keymap.set("n", "<leader>rr", with_save(zig_runner.smart_build_and_run), vim.tbl_extend("force", opts, { desc = "运行" }))

          -- Zig Build 项目快捷键（类似 CMake，使用 <leader>rc 组）
          vim.keymap.set("n", "<leader>rcb", zig_runner.zig_build, vim.tbl_extend("force", opts, { desc = "Zig Build" }))
          vim.keymap.set("n", "<leader>rcr", zig_runner.zig_build_run, vim.tbl_extend("force", opts, { desc = "Zig Build Run" }))
          vim.keymap.set("n", "<leader>rct", zig_runner.zig_build_test, vim.tbl_extend("force", opts, { desc = "Zig Build Test" }))
          vim.keymap.set("n", "<leader>rcl", zig_runner.zig_build_list, vim.tbl_extend("force", opts, { desc = "列出构建步骤" }))

          -- 测试快捷键
          vim.keymap.set("n", "<leader>rt", with_save(zig_runner.test_file), vim.tbl_extend("force", opts, { desc = "测试当前文件" }))
          vim.keymap.set("n", "<leader>rT", with_save(zig_runner.test_all), vim.tbl_extend("force", opts, { desc = "运行所有测试" }))

          -- 格式化和检查
          vim.keymap.set("n", "<leader>rF", zig_runner.format_file, vim.tbl_extend("force", opts, { desc = "格式化文件" }))
          vim.keymap.set("n", "<leader>rk", with_save(zig_runner.check_file), vim.tbl_extend("force", opts, { desc = "检查语法" }))

          -- 模板快捷键
          vim.keymap.set("n", "<leader>rni", zig_template.select_and_insert, vim.tbl_extend("force", opts, { desc = "插入模板" }))

          -- 版本信息
          vim.keymap.set("n", "<leader>rv", zig_runner.show_version, vim.tbl_extend("force", opts, { desc = "Zig 版本信息" }))

          -- 调试快捷键（与 C/C++ 统一使用 <leader>rd）
          vim.keymap.set("n", "<leader>rdd", function()
            vim.cmd("silent! write")
            local exe = zig_runner.compile_for_debug()

            -- 启动调试
            vim.schedule(function()
              local dap = require("dap")
              dap.run({
                name = "调试当前文件",
                type = "codelldb",
                request = "launch",
                program = exe,
                cwd = vim.fn.getcwd(),
                stopOnEntry = false,
              })
            end)
          end, vim.tbl_extend("force", opts, { desc = "快速调试当前文件" }))

          -- Zig Build 调试
          vim.keymap.set("n", "<leader>rdb", function()
            -- 询问可执行文件路径
            local exe = vim.fn.input({
              prompt = "可执行文件路径（zig-out/bin/）: ",
              default = vim.fn.getcwd() .. "/zig-out/bin/",
              completion = "file",
            })

            if exe == "" then
              return
            end

            local dap = require("dap")
            dap.run({
              name = "调试 Zig Build 项目",
              type = "codelldb",
              request = "launch",
              program = exe,
              cwd = vim.fn.getcwd(),
              stopOnEntry = false,
            })
          end, vim.tbl_extend("force", opts, { desc = "调试 Zig Build 项目" }))
        end,
      })
    end,
  },

  -- Mason 确保安装必要的工具
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "zls",        -- Zig Language Server
        "codelldb",   -- 调试器
      })
    end,
  },

  -- nvim-treesitter 支持 Zig
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "zig" })
      end
    end,
  },
}
