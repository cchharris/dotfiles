return {
    'sainnhe/gruvbox-material',
    lazy = false,
    priority = 1000,
    config = function()
        -- Optionally configure and load the colorscheme
        -- directly inside the plugin declaration.
        vim.g.gruvbox_material_enable_italic = true
        -- For dark version.
        vim.cmd.background = 'dark';

        -- For light version.
        -- vim.cmd.background='light';

        -- Set contrast.
        -- This configuration option should be placed before `colorscheme gruvbox-material`.
        -- Available values: 'hard', 'medium'(default), 'soft'
        vim.g.gruvbox_material_contrast_dark = 'hard'

        -- For better performance
        vim.g.gruvbox_material_better_performance = 1;
        -- vim.cmd.colorscheme('gruvbox-material') --auto-enable
    end
}
