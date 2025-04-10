return {
    'ghillb/cybu.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {},
    cmds = {
        'Cybu',
        'CybuPrev',
        'CybuNext',
        'CybuLastusedNext',
        'CybuLastusedPrev',
    },
    keys = {
        { '<C-k>', function() require('cybu').cycle('next') end, desc = "Cycle next buffer",     { silent = true, noremap = true } },
        { '<C-j>', function() require('cybu').cycle('prev') end, desc = "Cycle previous buffer", { silent = true, noremap = true } },
    },
}
