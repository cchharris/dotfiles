return {
    'nvim-mini/mini.move',
    opts = {
        mappings = {
            left = '<C-h>',
            right = '<C-l>',
            down = '<C-j>',
            up = '<C-k>',
        }
    },
    keys = {
        { "<C-h>", mode = { "n", "v" }, desc = "<MiniMove>  Move selection left" },
        { "<C-j>", mode = { "n", "v" }, desc = "<MiniMove>  Move selection down" },
        { "<C-k>", mode = { "n", "v" }, desc = "<MiniMove>  Move selection up" },
        { "<C-l>", mode = { "n", "v" }, desc = "<MiniMove>  Move selection right" },
    },
}
