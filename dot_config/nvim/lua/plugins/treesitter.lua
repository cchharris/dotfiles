-- On non-Windows, nix provides nvim-treesitter.withAllGrammars (parsers + queries) via packpath.
-- The plugin is only needed on Windows for parser installation.
-- vim.treesitter.start() autocmd lives in init.lua and runs on all platforms.
local is_windows = vim.fn.has("win32") == 1

return {
    "nvim-treesitter/nvim-treesitter",
    enabled = is_windows,
    branch = "main",
    event = "BufReadPost",
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").install({
            "bash", "c", "c_sharp", "cmake", "cpp", "css", "elixir",
            "git_config", "git_rebase", "gitattributes", "gitcommit", "gitignore",
            "gn", "html", "javascript", "json", "json5", "lua", "nix", "objc",
            "powershell", "printf", "python", "query", "requirements", "rust",
            "sql", "starlark", "terraform", "toml", "tsx", "typescript",
            "vim", "vimdoc", "xml", "yaml", "zsh",
        })
    end
}
