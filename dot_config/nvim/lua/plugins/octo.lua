return {
    'pwntester/octo.nvim',
    requires = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope.nvim',
        -- OR 'ibhagwan/fzf-lua',
        'nvim-tree/nvim-web-devicons',
    },
    opts = {},
    cmd = {
        'Octo'
    },
    keys = {
        {
            '<leader>ghr',
            '<cmd>Octo pr search involves:@me is:open<cr>',
            desc = '<Octo> Find Open PRs involving:@me'
        },
        {
            '<leader>ghm',
            '<cmd>Octo pr search author:@me<cr>',
            desc = '<Octo> Find my PRs',
        }
    },
}
