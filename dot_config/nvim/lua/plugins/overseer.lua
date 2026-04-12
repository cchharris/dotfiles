return {
    'stevearc/overseer.nvim',
    cmd = {
        'OverseerBuild',
        'OverseerClearCache',
        'OverseerClose',
        'OverseerDeleteBundle',
        'OverseerInfo',
        'OverseerLoadBundle',
        'OverseerOpen',
        'OverseerQuickAction',
        'OverseerRun',
        'OverseerRun',
        'OverseerRunCmd',
        'OverseerSaveBundle',
        'OverseerTaskAction',
        'OverseerToggle',
    },
    opts = {
        dap = false,
        strategy = {
            "toggleterm",
            open_on_start = false,
            close_on_exit = 'success',
        },
    },
    keys = {
        {
            '<leader>ot',
            function()
                require('overseer').toggle()
            end,
            desc = '<Overseer>  Toggle task list',
        },
        {
            '<leader>or',
            '<cmd>OverseerRun<cr>',
            desc = '<Overseer>  Run task template',
        },
        {
            '<leader>os',
            '<cmd>OverseerRunCmd<cr>',
            desc = '<Overseer>  Run shell command',
        },
        {
            '<leader>ob',
            function()
                local o = require('overseer')
                o.run_template({ tags = { o.TAG.BUILD } })
            end,
            desc = '<Overseer>  Build',
        }
    },
}
