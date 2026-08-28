return {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = true,
    priority = 1000,
    config = function()
        require('catppuccin').setup({
            flavour = 'mocha', -- matches Ghostty/wayle/SDDM theming elsewhere
            transparent_background = false,
            integrations = {
                blink_cmp = true,
                telescope = true,
                which_key = true,
                notify = true,
            },
        })
        -- vim.cmd.colorscheme('catppuccin') --auto-enable; nordic/south stay default otherwise
    end
}
