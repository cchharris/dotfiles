-- init.lua:
return {
    "gh-liu/fold_line.nvim",
    event = "VeryLazy",
    init = function()
        -- change the char of the line, see the `Appearance` section
        -- vim.g.fold_line_char_open_start = "╭"
        -- vim.g.fold_line_char_open_end = "╰"
    end,
}
