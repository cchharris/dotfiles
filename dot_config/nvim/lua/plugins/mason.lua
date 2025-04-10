-- See https://github.com/williamboman/mason-lspconfig.nvim
return {
	"williamboman/mason.nvim",
	 dependencies = {
        {
            "WhoIsSethDaniel/mason-tool-installer.nvim",
            opts = {
                ensureInstalled = {
                    "prettierd", -- prettier
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
	opts = { },
}
