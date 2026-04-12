-- See https://github.com/mason-org/mason-lspconfig.nvim
return {
    "mason-org/mason.nvim",
    dependencies = {
        {
            "WhoIsSethDaniel/mason-tool-installer.nvim",
            opts = {
                -- On non-Windows, nix provides formatters/linters — Mason must not
                -- try to install them (pre-compiled binaries don't work on NixOS).
                ensureInstalled = vim.fn.has("win32") == 1 and {
                    "prettierd",
                    "prettier",
                    "stylua",      -- lua formatter
                    "eslint_d",    -- js/ts linter
                    "hadolint",    -- dockerfile linter
                    "shellcheck",  -- bash/sh linter
                    "tflint",      -- terraform linter
                    "yamllint",    -- yaml linter
                    "gn-language-server",
                } or {},
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
