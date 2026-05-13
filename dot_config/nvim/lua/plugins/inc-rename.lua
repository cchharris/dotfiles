-- LSP rename with live preview. Pairs with noice's cmdline UI.
return {
    'smjonas/inc-rename.nvim',
    cmd = 'IncRename',
    opts = {},
    keys = {
        {
            '<leader>cr',
            function()
                return ':IncRename ' .. vim.fn.expand('<cword>')
            end,
            expr = true,
            desc = '<LSP>  Rename (incremental preview)',
        },
    },
}
