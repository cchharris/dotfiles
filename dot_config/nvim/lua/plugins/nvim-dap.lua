return {
    'mfussenegger/nvim-dap',
    config = function()
        require('overseer').enable_dap()
    end,
}
