local prettier_config = { "prettierd", "prettier", stop_after_first = true }

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
                css = prettier_config,
                graphql = prettier_config,
                html = prettier_config,
                javascript = prettier_config,
                javascriptreact = prettier_config,
                json = prettier_config,
                jsonc = prettier_config,
                lua = { 'stylua' },
                markdown = prettier_config,
                python = { 'ruff_fix', 'ruff_format', 'ruff_organize_imports' },
                scss = prettier_config,
                typescript = prettier_config,
                typescriptreact = prettier_config,
                yaml = prettier_config,
            },
            formatters = {
                prettierd = { cwd = prettier_cwd, require_cwd = false },
                prettier  = { cwd = prettier_cwd, require_cwd = false },
                stylua = {
                    cwd = util.root_file({ "stylua.toml", ".stylua.toml" }),
                    require_cwd = false,
                },
            },
            format_on_save = {
                timeout_ms = 500,
                lsp_format = "fallback",
            },
        })
    end,
}
