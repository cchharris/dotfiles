return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function ()
	local configs = require("nvim-treesitter.configs")
	  configs.setup({
	      ensure_installed = {
		"cmake",
		"git_config",
		"git_rebase",
		"gitattributes",
		"gitcommit",
		"gitignore",
		"printf",
		"sql",
		"starlark",
		"terraform",
		"starlark",
		"json",
		"bash",
		"powershell",
		"xml",
		"gn",
		"yaml",
	      "elixir",
	      "heex",
	      "html",
	      "javascript",
	      "lua",
	      "python",
	      "query",
	      "rust",
	      "typescript",
	      "vim",
	      "vimdoc",
	     "c",
	      },
	      sync_install = false,
	      highlight = { enable = true },
	      indent = { enable = true },
	    })
	end
}
