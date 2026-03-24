return {
    'mfussenegger/nvim-dap',
    dependencies = {
        'stevearc/overseer.nvim'
    },
    config = function()
        require('overseer').enable_dap()
    end,
}
