local prettier_config = { "prettierd", "prettier", stop_after_first = true }

return {
    'stevearc/conform.nvim',
    opts = {
        formatters_by_ft = {
            css = prettier_config,
            html = prettier_config,
            javascript = prettier_config,
            javascriptreact = prettier_config,
            lua = { 'stylua' },
            python = { 'ruff_fix', 'ruff_format', 'ruff_organize_imports' },
            typescript = prettier_config,
            typescriptreact = prettier_config,
        },
        format_on_save = {
            -- These options will be passed to conform.format()
            timeout_ms = 500,
            lsp_format = "fallback",
        },
    },
}
