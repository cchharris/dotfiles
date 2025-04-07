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
        },
    },
}
