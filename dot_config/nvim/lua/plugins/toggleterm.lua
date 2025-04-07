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
        },
        {
            '<C-h>', [[<cmd>wincmd h<cr>]], buffer = 0,
            mode = { 't' },
        },
        {
            '<C-j>', [[<cmd>wincmd j<cr>]], buffer = 0,
            mode = { 't' },
        },
        {
            '<C-k>', [[<cmd>wincmd k<cr>]], buffer = 0,
            mode = { 't' },
        },
        {
            '<C-l>', [[<cmd>wincmd l<cr>]], buffer = 0,
            mode = { 't' },
        },
    },
}
