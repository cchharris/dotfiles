return {
    'vuki656/package-info.nvim',
    dependencies = {
        'MunifTanjim/nui.nvim',
    },
    opts = {},
    keys = {
        { '<leader>is', function() require('package-info').show() end,           desc = "<PackageInfo> 󰏖 Show package versions",    silent = true, noremap = true },
        { '<leader>ic', function() require('package-info').hide() end,           desc = "<PackageInfo> 󰏖 Hide package versions",    silent = true, noremap = true },
        { '<leader>it', function() require('package-info').toggle() end,         desc = "<PackageInfo> 󰏖 Toggle package versions",  silent = true, noremap = true },
        { '<leader>iu', function() require('package-info').update() end,         desc = "<PackageInfo> 󰏖 Update package",           silent = true, noremap = true },
        { '<leader>id', function() require('package-info').delete() end,         desc = "<PackageInfo> 󰏖 Delete package",           silent = true, noremap = true },
        { '<leader>ii', function() require('package-info').install() end,        desc = "<PackageInfo> 󰏖 Install package",          silent = true, noremap = true },
        { '<leader>ip', function() require('package-info').change_version() end, desc = "<PackageInfo> 󰏖 Change package version",   silent = true, noremap = true },
    },
}
