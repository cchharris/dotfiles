local prettier_config = { "prettierd", "prettier", stop_after_first = true }

return {
    'stevearc/conform.nvim',
    dependencies = {
        -- Optional Discord-internal clint integration.
        -- Install discord-clint.nvim to enable clint as the primary formatter
        -- inside the Discord monorepo, falling back to standard formatters elsewhere.
        { "discord/discord-clint.nvim", optional = true },
    },
    config = function()
        local util = require("conform.util")
        local prettier_cwd = util.root_file({
            ".prettierrc", ".prettierrc.js", ".prettierrc.cjs", ".prettierrc.mjs",
            ".prettierrc.json", ".prettierrc.yaml", ".prettierrc.yml",
            "prettier.config.js", "prettier.config.cjs", "prettier.config.mjs",
            "package.json",
        })

        local conform = require("conform")

        conform.setup({
            formatters_by_ft = {
                css             = prettier_config,
                graphql         = prettier_config,
                html            = prettier_config,
                javascript      = prettier_config,
                javascriptreact = prettier_config,
                json            = prettier_config,
                jsonc           = prettier_config,
                lua             = { "stylua" },
                markdown        = prettier_config,
                python          = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
                scss            = prettier_config,
                typescript      = prettier_config,
                typescriptreact = prettier_config,
                yaml            = prettier_config,
            },
            formatters = {
                prettierd = { cwd = prettier_cwd, require_cwd = false },
                prettier  = { cwd = prettier_cwd, require_cwd = false },
                stylua    = {
                    cwd = util.root_file({ "stylua.toml", ".stylua.toml" }),
                    require_cwd = false,
                },
            },
            format_on_save = function(bufnr)
                local clint = package.loaded["discord-clint"]
                local in_discord = clint ~= nil
                    and vim.fs.root(bufnr, { "clint.config.ts" }) ~= nil
                return {
                    timeout_ms = in_discord and clint.timeout_ms or 500,
                    lsp_format = "fallback",
                }
            end,
        })

        -- If discord-clint is loaded, prepend clint to all formatter lists.
        -- Must happen after conform.setup() so formatters_by_ft is populated.
        local clint = package.loaded["discord-clint"]
        if clint then
            clint.inject(conform)
        end
    end,
}
