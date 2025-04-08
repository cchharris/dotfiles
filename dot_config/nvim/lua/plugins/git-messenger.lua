return {
    'rhysd/git-messenger.vim',
    cmd = { 'GitMessenger' },
    keys = {
        {
            '<leader>gm',
            '<cmd>GitMessenger<cr>',
            desc = 'See git commit message'
        },
    },
}
