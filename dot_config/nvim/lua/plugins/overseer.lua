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
}
