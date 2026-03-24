return {
    'akinsho/bufferline.nvim',
    version = "*",
    event = { "BufRead", "BufNewFile" },
    dependencies = 'nvim-tree/nvim-web-devicons',
    opts = {
        options = {
            offsets = {
                {
                    filetype = "neo-tree",
                    text = "File Explorer",
                    text_align = "center",
                    highlight = "Directory",
                    separator = true
                }
            }
        }
    },
    keys = {
        {
            '<leader>bp',
            function()
                require('bufferline').pick_buffer()
            end,
            desc = "<Bufferline> Pick buffer",
        },
    },
}
