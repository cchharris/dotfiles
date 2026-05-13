-- Render variable values as virtual text next to their declarations during DAP sessions.
return {
    'theHamsta/nvim-dap-virtual-text',
    lazy = true,
    dependencies = {
        'mfussenegger/nvim-dap',
        'nvim-treesitter/nvim-treesitter',
    },
    opts = {
        commented = true,
        all_references = true,
        virt_text_pos = 'eol',
    },
}
