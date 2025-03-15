--  e.g. ~/.local/share/chezmoi/*
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { vim.fs.normalize(vim.fs.joinpath("~", ".local", "share", "chezmoi", "*")) },
    callback = function(ev)
        local bufnr = ev.buf
        local edit_watch = function()
            require("chezmoi.commands.__edit").watch(bufnr)
        end
        vim.schedule(edit_watch)
    end,
})
