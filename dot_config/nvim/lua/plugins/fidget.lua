-- Standalone LSP progress UI. Particularly valuable for slow indexers (clangd
-- on large native projects, pyrefly warming up).
return {
    'j-hui/fidget.nvim',
    event = 'LspAttach',
    opts = {
        progress = {
            display = {
                done_ttl = 2,
            },
        },
        notification = {
            window = {
                winblend = 0,
            },
        },
    },
}
