vim.api.nvim_command('set runtimepath^=~/.config/nvim')
vim.api.nvim_command('let &packpath = &runtimepath')
vim.api.nvim_command('source ~/.config/nvim/init.lua')
