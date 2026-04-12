local is_windows = vim.fn.has("win32") == 1

return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    event = "BufReadPost",
    -- On non-Windows, nix provides nvim-treesitter.withAllGrammars via packpath.
    -- No build step or manual grammar installation needed.
    build = is_windows and ":TSUpdate" or nil,
    config = function()
        if is_windows then
            require("nvim-treesitter").install({
                "bash", "c", "cmake", "cpp", "css", "elixir",
                "git_config", "git_rebase", "gitattributes", "gitcommit", "gitignore",
                "gn", "html", "javascript", "json", "json5", "lua", "nix", "objc",
                "powershell", "printf", "python", "query", "requirements", "rust",
                "sql", "starlark", "terraform", "toml", "tsx", "typescript",
                "vim", "vimdoc", "xml", "yaml", "zsh",
            })
        end
        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("EnableTreesitterHighlighting", { clear = true }),
            desc = "Try to enable tree-sitter syntax highlighting",
            pattern = '*',
            callback = function()
                pcall(function() vim.treesitter.start() end)
            end
        })
    end
}
