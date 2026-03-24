local prettier_config = { "prettierd", "prettier", stop_after_first = true }

-- Filetypes where clint handles formatting, with fallback for non-Discord projects
local clint_or_prettier = { "clint", "prettierd", "prettier", stop_after_first = true }

return {
    'stevearc/conform.nvim',
    config = function()
        local util = require("conform.util")
        local prettier_cwd = util.root_file({
            ".prettierrc", ".prettierrc.js", ".prettierrc.cjs", ".prettierrc.mjs",
            ".prettierrc.json", ".prettierrc.yaml", ".prettierrc.yml",
            "prettier.config.js", "prettier.config.cjs", "prettier.config.mjs",
            "package.json",
        })

        require("conform").setup({
            formatters_by_ft = {
                -- clint handles these; falls back to direct formatters outside Discord
                css              = clint_or_prettier,
                javascript       = clint_or_prettier,
                javascriptreact  = clint_or_prettier,
                scss             = clint_or_prettier,
                typescript       = clint_or_prettier,
                typescriptreact  = clint_or_prettier,
                python           = { "clint", "ruff_fix", "ruff_format", "ruff_organize_imports", stop_after_first = true },
                rust             = { "clint", stop_after_first = true },   -- lsp_format fallback if outside Discord
                terraform        = { "clint", stop_after_first = true },

                -- Not covered by clint — always use direct formatters
                graphql  = prettier_config,
                html     = prettier_config,
                json     = prettier_config,
                jsonc    = prettier_config,
                lua      = { "stylua" },
                markdown = prettier_config,
                yaml     = prettier_config,
            },

            formatters = {
                clint = {
                    command = function(ctx)
                        local root = vim.fs.root(ctx.buf, { "clint.config.ts" })
                        return vim.fs.joinpath(root, ".local", "bin", "clint")
                    end,
                    args = { "fmt", "--fix", "--no-color", "$FILENAME" },
                    stdin = false,
                    cwd = function(ctx)
                        return vim.fs.root(ctx.buf, { "clint.config.ts" })
                    end,
                    condition = function(ctx)
                        return vim.fs.root(ctx.buf, { "clint.config.ts" }) ~= nil
                    end,
                },
                prettierd = { cwd = prettier_cwd, require_cwd = false },
                prettier  = { cwd = prettier_cwd, require_cwd = false },
                stylua = {
                    cwd = util.root_file({ "stylua.toml", ".stylua.toml" }),
                    require_cwd = false,
                },
            },

            format_on_save = function(bufnr)
                local in_discord = vim.fs.root(bufnr, { "clint.config.ts" }) ~= nil
                return {
                    -- clint spins up kix/nix tooling so needs more time
                    timeout_ms = in_discord and 5000 or 500,
                    lsp_format = "fallback",
                }
            end,
        })
    end,
}
