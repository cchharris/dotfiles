-- Buffer-based project search/replace. Backed by ripgrep; supports ast-grep
-- for structural search if you have `sg` installed.
return {
    'MagicDuck/grug-far.nvim',
    cmd = { 'GrugFar', 'GrugFarWithin' },
    opts = {
        headerMaxWidth = 80,
    },
    keys = {
        {
            '<leader>rg',
            function() require('grug-far').open() end,
            mode = { 'n' },
            desc = '<Grug-Far>  Search/replace at cwd',
        },
        {
            '<leader>rw',
            function()
                require('grug-far').open({ prefills = { search = vim.fn.expand('<cword>') } })
            end,
            mode = { 'n' },
            desc = '<Grug-Far>  Search/replace word under cursor',
        },
        {
            '<leader>rv',
            function() require('grug-far').with_visual_selection() end,
            mode = { 'v' },
            desc = '<Grug-Far>  Search/replace visual selection',
        },
        {
            '<leader>rf',
            function()
                require('grug-far').open({ prefills = { paths = vim.fn.expand('%') } })
            end,
            mode = { 'n' },
            desc = '<Grug-Far>  Search/replace current file',
        },
    },
}
