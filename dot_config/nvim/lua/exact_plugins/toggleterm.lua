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
