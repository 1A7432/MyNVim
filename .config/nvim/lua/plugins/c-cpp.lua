-- C/C++ 开发配置
-- 支持三种构建系统：单文件编译、CMake 项目、Makefile 项目
-- 包含编译、运行、调试、竞赛编程等功能

return {
  -- cmake-tools.nvim 配置
  {
    "Civitasv/cmake-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    ft = { "c", "cpp", "cmake" },
    opts = {
      cmake_command = "cmake",
      cmake_build_directory = "build",
      cmake_build_directory_prefix = "",
      cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
      cmake_build_options = {},
      cmake_soft_link_compile_commands = true,
      cmake_compile_commands_from_lsp = false,
      cmake_kits_path = nil,
      cmake_dap_configuration = {
        name = "cpp",
        type = "codelldb",
        request = "launch",
      },
      cmake_executor = {
        name = "quickfix",
        opts = {},
      },
      cmake_runner = {
        name = "terminal",
        opts = {},
      },
      cmake_notifications = {
        enabled = true,
        spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
      },
    },
  },

  -- clangd LSP 配置增强
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
          },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
        },
      },
    },
  },

  -- which-key 快捷键提示
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>r", group = "运行/编译", icon = "" },
        { "<leader>rc", group = "CMake", icon = "" },
        { "<leader>rp", group = "竞赛编程", icon = "" },
        { "<leader>rd", group = "调试", icon = "" },
      },
    },
  },

  -- 自定义快捷键和自动命令
  {
    "LazyVim/LazyVim",
    opts = function()
      -- 加载 C++ 工具模块
      local cpp_runner = require("dirac.cpp.runner")
      local cpp_competitive = require("dirac.cpp.competitive")

      -- 设置快捷键（仅在 C/C++ 文件中生效）
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "c", "cpp" },
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

          -- Make 编译运行快捷键（第一层）
          vim.keymap.set("n", "<leader>rb", cpp_runner.make_build, vim.tbl_extend("force", opts, { desc = "Make 编译" }))
          vim.keymap.set("n", "<leader>rr", cpp_runner.make_run, vim.tbl_extend("force", opts, { desc = "Make 运行" }))
          vim.keymap.set("n", "<leader>rt", cpp_runner.make_test, vim.tbl_extend("force", opts, { desc = "Make 测试" }))
          vim.keymap.set("n", "<leader>rx", cpp_runner.make_clean, vim.tbl_extend("force", opts, { desc = "Make 清理" }))
          vim.keymap.set("n", "<leader>ri", cpp_runner.make_install, vim.tbl_extend("force", opts, { desc = "Make 安装" }))
          vim.keymap.set("n", "<leader>rs", with_save(cpp_runner.smart_build_and_run), vim.tbl_extend("force", opts, { desc = "智能编译运行" }))

          -- 单文件快速编译运行
          vim.keymap.set("n", "<leader>rf", with_save(cpp_runner.compile_and_run), vim.tbl_extend("force", opts, { desc = "单文件编译运行" }))

          -- CMake 项目快捷键（第二层 rc 组）
          vim.keymap.set("n", "<leader>rcb", "<cmd>CMakeBuild<cr>", vim.tbl_extend("force", opts, { desc = "CMake 编译" }))
          vim.keymap.set("n", "<leader>rcr", "<cmd>CMakeRun<cr>", vim.tbl_extend("force", opts, { desc = "CMake 运行" }))
          vim.keymap.set("n", "<leader>rcc", "<cmd>CMakeGenerate<cr>", vim.tbl_extend("force", opts, { desc = "CMake 配置" }))
          vim.keymap.set("n", "<leader>rcs", "<cmd>CMakeSelectBuildTarget<cr>", vim.tbl_extend("force", opts, { desc = "选择构建目标" }))
          vim.keymap.set("n", "<leader>rct", "<cmd>CMakeRunTest<cr>", vim.tbl_extend("force", opts, { desc = "CMake 测试" }))
          vim.keymap.set("n", "<leader>rcd", "<cmd>CMakeSelectBuildType<cr>", vim.tbl_extend("force", opts, { desc = "选择构建类型" }))
          vim.keymap.set("n", "<leader>rcx", "<cmd>CMakeClean<cr>", vim.tbl_extend("force", opts, { desc = "CMake 清理" }))

          -- 竞赛编程快捷键
          vim.keymap.set("n", "<leader>rpt", with_save(cpp_competitive.test_with_input), vim.tbl_extend("force", opts, { desc = "测试（用 input.txt）" }))
          vim.keymap.set("n", "<leader>rpc", cpp_competitive.compare_output, vim.tbl_extend("force", opts, { desc = "比对输出" }))
          vim.keymap.set("n", "<leader>rpb", with_save(cpp_competitive.batch_test), vim.tbl_extend("force", opts, { desc = "批量测试" }))
          vim.keymap.set("n", "<leader>rpr", with_save(cpp_competitive.quick_run), vim.tbl_extend("force", opts, { desc = "快速运行" }))
          vim.keymap.set("n", "<leader>rps", cpp_competitive.create_template, vim.tbl_extend("force", opts, { desc = "创建竞赛模板" }))
          vim.keymap.set("n", "<leader>rpi", cpp_competitive.edit_input, vim.tbl_extend("force", opts, { desc = "编辑输入文件" }))
          vim.keymap.set("n", "<leader>rpe", cpp_competitive.edit_expected, vim.tbl_extend("force", opts, { desc = "编辑期望输出" }))
          vim.keymap.set("n", "<leader>rpo", cpp_competitive.show_output, vim.tbl_extend("force", opts, { desc = "查看输出" }))

          -- 调试快捷键（单文件快速调试）
          vim.keymap.set("n", "<leader>rdd", function()
            vim.cmd("silent! write")
            local exe = cpp_runner.compile_for_debug()

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

          -- CMake 调试（需要先选择目标）
          vim.keymap.set("n", "<leader>rdb", function()
            vim.cmd("CMakeSelectBuildType")
            vim.defer_fn(function()
              vim.cmd("CMakeBuild")
              vim.defer_fn(function()
                vim.cmd("CMakeDebug")
              end, 500)
            end, 100)
          end, vim.tbl_extend("force", opts, { desc = "CMake 编译并调试" }))
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
        "clangd",
        "clang-format",
        "codelldb",
        "cmake-language-server",
        "cmakelang",
        "cmakelint",
      })
    end,
  },
}
