-- See https://github.com/mason-org/mason-lspconfig.nvim
return {
    "mason-org/mason.nvim",
    dependencies = {
        {
            "WhoIsSethDaniel/mason-tool-installer.nvim",
            opts = {
                ensureInstalled = {
                    "prettierd",
                    "prettier",
                    "stylua",      -- lua formatter
                    "eslint_d",    -- js/ts linter
                    "hadolint",    -- dockerfile linter
                    "shellcheck",  -- bash/sh linter
                    "tflint",      -- terraform linter
                    "yamllint",    -- yaml linter
                },
            },
        },
    },
    cmd = {
        'Mason',
        'MasonLog',
        'MasonUpdate',
        'MasonInstall',
        'MasonUninstall',
        'MasonUninstallAll',
        'MasonToolsClean',
        'MasonToolsUpdate',
        'MasonToolsInstall',
        'MasonToolsUpdateSync',
        'MasonToolsInstallSync',
    },
    opts = {},
}
