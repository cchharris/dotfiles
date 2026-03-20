local prettier_config = { "prettierd", "prettier", stop_after_first = true }

return {
    'stevearc/conform.nvim',
    opts = {
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
        format_on_save = {
            -- These options will be passed to conform.format()
            timeout_ms = 500,
            lsp_format = "fallback",
        },
    },
}
