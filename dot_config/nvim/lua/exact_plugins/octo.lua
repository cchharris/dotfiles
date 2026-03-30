return {
    'pwntester/octo.nvim',
    requires = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope.nvim',
        -- OR 'ibhagwan/fzf-lua',
        'nvim-tree/nvim-web-devicons',
    },
    opts = {
        enable_builtin = true,
    },
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
        },
        {
            '<leader>ghW',
            function()
                vim.fn.jobstart("gh search prs --author @me --state open --archived=false --web", { detach = true })
            end,
            desc = '<GitHub> Open my PRs in browser',
        },
        {
            '<leader>ghV',
            function()
                vim.fn.jobstart("gh search prs --involves @me --state open --archived=false --web", { detach = true })
            end,
            desc = '<GitHub> Open PRs involving @me in browser',
        },
        {
            '<leader>ghs',
            function()
                require('octo.utils').create_base_search_command({ include_prs = true })
            end,
            desc = '<GitHub> Search Github'
        },
    },
}
