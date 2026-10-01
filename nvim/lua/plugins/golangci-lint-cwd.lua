return {
  -- golangci-lint's cwd defaults to Neovim's own process cwd (see
  -- nvim-lint's lint.lua: `opts.cwd or linter.cwd or vim.fn.getcwd()`),
  -- not the buffer's module root. In a go.work multi-module workspace,
  -- opening Neovim from outside the module (e.g. `nvim ..` from the
  -- parent of go.work) makes go.work resolution fail for golangci-lint's
  -- typecheck linter, even though gopls resolves it correctly. Point
  -- golangci-lint's cwd at the buffer's own root each time a Go buffer
  -- is entered.
  "mfussenegger/nvim-lint",
  optional = true,
  opts = function(_, opts)
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "*.go",
      callback = function(args)
        local root = vim.fs.root(args.buf, { "go.work", "go.mod", ".git" })
        local ok, lint = pcall(require, "lint")
        if ok and root and lint.linters.golangcilint then
          lint.linters.golangcilint.cwd = root
        end
      end,
    })
    return opts
  end,
}
