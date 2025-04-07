return {
    'vuki656/package-info.nvim',
    dependencies = {
        'MunifTanjim/nui.nvim',
    },
    opts = {
    },
    keys = {
        {
            '<leader>is', function() require('package-info').show() end,
            { silent=true, noremap = true , desc = "Show package info" },
        },
        {
            '<leader>ic', function() require('package-info').hide() end,
            { silent=true, noremap = true , desc = "Show package info" },
        },
        {
            '<leader>it', function() require('package-info').toggle() end,
            { silent=true, noremap = true , desc = "Show package info" },
        },
        {
            '<leader>iu', function() require('package-info').update() end,
            { silent=true, noremap = true , desc = "Show package info" },
        },
        {
            '<leader>id', function() require('package-info').delete() end,
            { silent=true, noremap = true , desc = "Show package info" },
        },
        {
            '<leader>ii', function() require('package-info').install() end,
            { silent=true, noremap = true , desc = "Show package info" },
        },
        {
            '<leader>ip', function() require('package-info').change_version() end,
            { silent=true, noremap = true , desc = "Show package info" },
        },
    },
}

