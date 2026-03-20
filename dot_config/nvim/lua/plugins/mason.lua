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
                    "stylua",    -- lua formatter
                    "tflint",    -- terraform linter
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
