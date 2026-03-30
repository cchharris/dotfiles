return {
    'akinsho/toggleterm.nvim',
    version = "*",
    cmd = {
        'ToggleTerm',
        'ToggleTermSendCurrentLine',
        'ToggleTermSendVisualLines',
        'ToggleTermSendVisualSelection',
        'ToggleTermSetName',
        'ToggleTermToggleAll',
        'TermExec',
        'TermNew',
        'TermSelect',
    },
    opts = {
    },
    keys = {
        {
            '<leader>Tn',
            function()
                local Terminal = require('toggleterm.terminal').Terminal
                local focused = require('toggleterm.terminal').get_focused_terminal()
                local direction = focused and focused.direction or 'horizontal'
                Terminal:new({ direction = direction }):toggle()
            end,
            mode = { 'n' },
            desc = '<ToggleTerm>  New terminal (same direction)',
        },
        {
            '<C-t>',
            function()
                local Terminal = require('toggleterm.terminal').Terminal
                local focused = require('toggleterm.terminal').get_focused_terminal()
                local direction = focused and focused.direction or 'horizontal'
                Terminal:new({ direction = direction }):toggle()
            end,
            buffer = 0,
            mode = { 't' },
            desc = '<ToggleTerm>  New terminal (same direction)',
        },
        {
            '<esc>', [[<C-\><C-n>]], buffer = 0,
            mode = { 't' },
            desc = "<ToggleTerm>  Exit terminal mode",
        },
        {
            '<C-h>', [[<cmd>wincmd h<cr>]], buffer = 0,
            mode = { 't' },
            desc = "<ToggleTerm>  Move to left window",
        },
        {
            '<C-j>', [[<cmd>wincmd j<cr>]], buffer = 0,
            mode = { 't' },
            desc = "<ToggleTerm>  Move to bottom window",
        },
        {
            '<C-k>', [[<cmd>wincmd k<cr>]], buffer = 0,
            mode = { 't' },
            desc = "<ToggleTerm>  Move to top window",
        },
        {
            '<C-l>', [[<cmd>wincmd l<cr>]], buffer = 0,
            mode = { 't' },
            desc = "<ToggleTerm>  Move to right window",
        },
    },
}
