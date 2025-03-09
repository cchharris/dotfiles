-- See https://github.com/williamboman/mason-lspconfig.nvim
return {
	"williamboman/mason.nvim",
	 dependencies = { "williamboman/mason-lspconfig.nvim", "WhoIsSethDaniel/mason-tool-installer.nvim" },
	config = function()
		require("mason").setup({ })
		require("mason-lspconfig").setup({
		ensure_installed = {
			"basedpyright", -- python
			"bashls", -- bash
			"buf_ls", -- protobuf
			"clangd", -- c, c++
			"cmake", -- cmake
			"dockerls", -- docker
			"html", -- html
			"ts_ls", -- typescript, javascript
			"lua_ls", -- lua
			"nil_ls", -- nix
			"ruff", -- python
			"rust_analyzer", -- rust
			"bzl", -- bazel/skylark
			"terraformls", -- terraform
			"tflint", -- terraform
			--"harper_ls", -- toml, typescript, rust, ruby, python, markdown, lua, javascript, java, C, C++, C#
			"taplo", -- toml
			"vimls", -- vimscript
			"yamlls", -- yaml
			"zls", -- zig
			"grammarly", -- text, markdown
			"powershell_es", -- powershell
			"jsonls", -- json
		}
		})
	end
}
