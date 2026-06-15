-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = false
vim.opt.colorcolumn = "80"

-- Disable built-in sqlcomplete which maps arrow keys in insert mode and flashes warnings
vim.g.loaded_sql_completion = 1
