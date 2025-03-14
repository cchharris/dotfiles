return {
	'nvim-lualine/lualine.nvim',
	dependencies = {
		'nvim-tree/nvim-web-devicons',
		'AndreM222/copilot-lualine',
	},
	opts = {
	  sections = {
		lualine_a = {'mode'},
		lualine_b = {'branch', 'diff', 'diagnostics'},
		lualine_c = {{'filename', path=1}},
		lualine_x = {'searchcount', 'selectioncount', 'lsp_status', 'encoding', 'fileformat', 'filetype'},
		lualine_y = {'progress'},
		lualine_z = {'location'}
	  },
	  inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {{'filename', path=1}},
		lualine_x = {'location'},
		lualine_y = {},
		lualine_z = {}
	  },
	}
}
