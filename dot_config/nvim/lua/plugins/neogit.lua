return {
    "NeogitOrg/neogit",
    dependencies = {
        "nvim-lua/plenary.nvim", -- required
        "sindrets/diffview.nvim", -- optional - Diff integration

        -- Only one of these is needed.
        "nvim-telescope/telescope.nvim", -- optional
        --"ibhagwan/fzf-lua",              -- optional
        --"nvim-mini/mini.pick",         -- optional
    },
    cmd = { "Neogit", "NeogitCommit", "NeogitLogCurrent", "NeogitResetState" },
    keys = {
        { "<leader>gg", "<cmd>Neogit<cr>", desc = "󰊢 Open Neogit" },
        { "<leader>gc", "<cmd>NeogitCommit<cr>", desc = " Neogit Commit" },
    },
    config = true
}
