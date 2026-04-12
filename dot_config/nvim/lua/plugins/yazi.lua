---@type LazySpec
return {
    "mikavilpas/yazi.nvim",
    cond = vim.fn.has('win32') == 0,
    version = "*", -- use the latest stable version
    event = "VeryLazy",
    dependencies = {
        { "nvim-lua/plenary.nvim", lazy = true },
    },
    keys = {
        -- 👇 in this section, choose your own keymappings!
        {
            "<leader>-",
            mode = { "n", "v" },
            "<cmd>Yazi<cr>",
            desc = "<Yazi>  Open at current file",
        },
        {
            -- Open in the current working directory
            "<leader>cw",
            "<cmd>Yazi cwd<cr>",
            desc = "<Yazi>  Open in working directory",
        },
        {
            "<c-up>",
            "<cmd>Yazi toggle<cr>",
            desc = "<Yazi>  Resume last session",
        },
    },
    ---@type YaziConfig | {}
    opts = {
        -- if you want to open yazi instead of netrw, see below for more info
        open_for_directories = true,
        keymaps = {
            show_help = "<f1>",
        },
    },
}
