return {
    'nvim-telescope/telescope.nvim', --tag = '0.1.8',
-- or                              , branch = '0.1.x',
      dependencies = {
	'nvim-lua/plenary.nvim',
	'nvim-telescope/telescope-live-grep-args.nvim',
	},
	keys = {
		{'<leader>fcz',
			function()
				require('telescope').extensions.chezmoi.find_files()
			end,
			desc = '<Telescope> Find files in chezmoi',
		},
		{'<leader>fca',
			function()
				require('telescope.builtin').find_files({
					cwd = vim.fs.normalize(vim.fs.joinpath("~", ".local", "share", "chezmoi")),
					hidden = true,
					no_ignore = true,
					no_ignore_parent = true
				})
			end,
			desc = '<Telescope> Find files in chezmoi',
		},

		{'<leader>fcr',
			function()
				require('telescope').extensions.live_grep_args.live_grep_args({search_dirs = { vim.fs.normalize(vim.fs.joinpath("~", ".local", "share", "chezmoi"))} })
			end,
			desc = '<Telescope> Find in files in chezmoi',
		},
		{'<leader>fr',
			function()
				require('telescope').extensions.live_grep_args.live_grep_args()
			end,
			desc = "<Telescope> Live grep with args"
		},
		{'<leader>fb',
			function()
				require('telescope.builtin').buffers()
			end,
			desc = "<Telescope> Buffers"
		},
		{'<leader>ff',
			function()
				require('telescope.builtin').fd()
			end,
			desc = "<Telescope> Find files"
		},
			-- status, commits, bcommits, branches
		{'<leader>fgb',
			function()
				require('telescope.builtin').git_branches()
			end,
			desc = "<Telescope> Git branches"
		},
		{'<leader>fgc',
			function()
				require('telescope.builtin').git_commits()
			end,
			desc = "<Telescope> Git commits"}
			,
		{'<leader>fgs',
			function()
				require('telescope.builtin').git_status()
			end,
			desc = "<Telescope> Git status"
		},
		{'<leader>fgf',
			function()
				require('telescope.builtin').git_bcommits()
			end,
			desc = "<Telescope> Git bcommits"
		},
	},
	config = function()
		local telescope = require('telescope')

		telescope.setup {
		  defaults = {
		    -- Default configuration for telescope goes here:
		    -- config_key = value,
		    mappings = {
		      i = {
			-- map actions.which_key to <C-h> (default: <C-/>)
			-- actions.which_key shows the mappings for your picker,
			-- e.g. git_{create, delete, ...}_branch for the git_branches picker
			["<C-h>"] = "which_key",
		      }
		    }
		  },
		  pickers = {
		    -- Default configuration for builtin pickers goes here:
		    -- picker_name = {
		    --   picker_config_key = value,
		    --   ...
		    -- }
		    -- Now the picker_config_key will be applied every time you call this
		    -- builtin picker
		  },
		  extensions = {
		    -- Your extension configuration goes here:
		    -- extension_name = {
		    --   extension_config_key = value,
		    -- }
		    -- please take a look at the readme of the extension you want to configure
		  }
		}

		telescope.load_extension('chezmoi')
		telescope.load_extension('live_grep_args')
		telescope.load_extension('neoclip')
	end
    }
