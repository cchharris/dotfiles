return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    event = "VeryLazy",
    build = ":TSUpdate",
    config = function()
        local ts = require("nvim-treesitter")
        ts.install({
            "bash",
            "c",
            "cmake",
            "cpp",
            "css",
            "elixir",
            "git_config",
            "git_rebase",
            "gitattributes",
            "gitcommit",
            "gitignore",
            "gn",
            "html",
            "javascript",
            "json",
            "json5",
            "lua",
            "nix",
            "objc",
            "powershell",
            "printf",
            "python",
            "query",
            "requirements",
            "rust",
            "sql",
            "starlark",
            "terraform",
            "toml",
            "tsx",
            "typescript",
            "vim",
            "vimdoc",
            "xml",
            "yaml",
            "zsh",
        });
        -- vim.api.nvim_create_autocmd("FileType", {
        --     group = vim.api.nvim_create_augroup("EnableTreesitterHighlighting", { clear = true }),
        --     desc = "Try to enable tree-sitter syntax highlighting",
        --     pattern = '*',
        --     callback = function()
        --         pcall(function() vim.treesitter.start() end)
        --     end
        -- })
    end
}
