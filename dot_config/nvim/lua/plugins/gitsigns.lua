return {
    "lewis6991/gitsigns.nvim",
    event = { 'BufNewFile', 'BufReadPost' },
    cmd = { 'Gitsigns' },
    opts = {
        current_line_blame = true,
        current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
            delay = 1000,
        },
        numhl = true,
    },
    keys = {
        {
            "]g",
            "<cmd>Gitsigns next_hunk<cr>",
            desc = "<Gitsigns>  Go to next git hunk"
        },
        {
            "[g",
            "<cmd>Gitsigns prev_hunk<cr>",
            desc = "<Gitsigns>  Go to previous git hunk"
        },
        {
            "<leader>gb",
            "<cmd>Gitsigns blame_line<cr>",
            desc = "<Gitsigns>  Open git blame"
        },
        {
            "<leader>gB",
            "<cmd>Gitsigns blame<cr>",
            desc = "<Gitsigns>  Open git blame for buffer"
        },
        {
            "<leader>gd",
            "<cmd>Gitsigns diffthis<cr>",
            desc = "<Gitsigns>  Open diff"
        },
        {
            "<leader>gp",
            "<cmd>Gitsigns preview_hunk<cr>",
            desc = "<Gitsigns>  Preview hunk"
        },
        {
            "<leader>gP",
            "<cmd>Gitsigns preview_hunk_inline<cr>",
            desc = "<Gitsigns>  Preview hunk inline"
        },
    }
}
