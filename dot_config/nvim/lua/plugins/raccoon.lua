-- Alternative to octo.nvim for browsing/reviewing GitHub PRs.
-- Tokens must be set out-of-band in ~/.config/raccoon/config.json (run `:Raccoon config`).
return {
    'bajor/nvim-raccoon',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = { 'Raccoon' },
    config = function()
        require('raccoon').setup({
            -- raccoon registers its own keymaps via the `shortcuts` table; remap to a
            -- <leader>gR prefix so it doesn't clash with octo's <leader>gh* bindings.
            shortcuts = {
                pr_list              = '<leader>gRr',
                show_shortcuts       = '<leader>gR?',
                next_point           = ']r',
                prev_point           = '[r',
                next_file            = ']R',
                prev_file            = '[R',
                next_thread          = ']t',
                prev_thread          = '[t',
                comment              = '<leader>gRc',
                description          = '<leader>gRd',
                list_comments        = '<leader>gRl',
                merge                = '<leader>gRm',
                commit_viewer_toggle = '<leader>gRv',
                close                = '<leader>gRq',
            },
        })
    end,
    keys = {
        { '<leader>gRr', '<cmd>Raccoon pr_list<cr>',         desc = '<Raccoon> PR list' },
        { '<leader>gRl', '<cmd>Raccoon local<cr>',           desc = '<Raccoon> Local commit viewer' },
        { '<leader>gRC', '<cmd>Raccoon config<cr>',          desc = '<Raccoon> Open config' },
    },
}
