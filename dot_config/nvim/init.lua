require("config.lazy")
require("config.chezmoi")

require('config.keymaps')

--vim.cmd [[colorscheme habamax]]
vim.cmd [[set relativenumber]]
vim.cmd [[set number]]
vim.cmd [[set cursorline]]
vim.cmd [[set tabstop=4]]
vim.cmd [[set shiftwidth=4]]
vim.cmd [[set clipboard+=unnamedplus]]

vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
