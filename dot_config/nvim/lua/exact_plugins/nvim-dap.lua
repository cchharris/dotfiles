return {
    'mfussenegger/nvim-dap',
    cmd = { "DapContinue", "DapToggleBreakpoint", "DapStepOver", "DapStepInto", "DapStepOut", "DapNew" },
    dependencies = {
        'stevearc/overseer.nvim'
    },
    config = function()
        require('overseer').enable_dap()
    end,
}
