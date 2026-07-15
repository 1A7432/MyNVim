return {
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      -- JDTLS 自身必须由 Java 21+ 启动；项目目标版本仍由各项目配置决定。
      local java_home = vim.fn.trim(vim.fn.system({ "/usr/libexec/java_home", "-v", "21" }))
      if vim.v.shell_error ~= 0 or vim.fn.executable(java_home .. "/bin/java") ~= 1 then
        error("未找到可用于启动 JDTLS 的 Java 21")
      end

      opts.cmd = opts.cmd or { vim.fn.exepath("jdtls") }
      table.insert(opts.cmd, "--java-executable=" .. java_home .. "/bin/java")
      return opts
    end,
  },
}
