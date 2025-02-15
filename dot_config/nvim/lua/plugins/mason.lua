return {
	"williamboman/mason.nvim",
	 dependencies = { "williamboman/mason-lspconfig.nvim", "WhoIsSethDaniel/mason-tool-installer.nvim" },
	config = function()
		require("mason").setup({ })
		require("mason-lspconfig").setup({
		ensure_installed = {
			"bashls",
			"clangd",
			"cmake",
			"dockerls",
			"html",
			"ts_ls",
			"lua_ls",
			"nil_ls",
			"pylint",
			"pyright",
			"ruff",
			"rust_analyzer",
			"bzl",
			"terraformls",
			"tflint",
			"harper_ls",
			"vimls",
			"bashls"
		}
		})
	end
}
