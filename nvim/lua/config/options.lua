-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = true
vim.opt.colorcolumn = "80"

-- Python: use basedpyright (pyright fork with inlay hints) instead of pyright.
-- Read by lazyvim.plugins.extras.lang.python at spec load, so it must be set here.
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = "ruff"
