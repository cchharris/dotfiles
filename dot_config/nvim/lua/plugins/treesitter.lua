return {
	"nvim-treesitter/nvim-treesitter",
	event = "VeryLazy",
	build = ":TSUpdate",
	config = function ()
	local configs = require("nvim-treesitter.configs")
	  configs.setup({
	      ensure_installed = {
			"bash",
			"c",
			"cmake",
			"elixir",
			"git_config",
			"git_rebase",
			"gitattributes",
			"gitcommit",
			"gitignore",
			"gn",
			"html",
			"javascript",
			"json",
			"lua",
			"powershell",
			"printf",
			"python",
			"query",
			"rust",
			"sql",
			"starlark",
			"terraform",
			"typescript",
			"vim",
			"vimdoc",
			"xml",
			"yaml",
	      },
	      sync_install = false,
	      highlight = { enable = true },
	      indent = { enable = true },
	    })
	end
}
