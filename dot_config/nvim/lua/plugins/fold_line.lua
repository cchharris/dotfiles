-- init.lua:
return {
    "gh-liu/fold_line.nvim",
    event = "VeryLazy",
    init = function()
        vim.g.fold_line_bar_pos_strategy = "indent"
    end,
}
