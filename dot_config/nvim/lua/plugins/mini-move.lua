return {
	'echasnovski/mini.move',
	config = function()
		require('mini.move').setup({
		mappings = {
			left = '<C-h>',
			right = '<C-l>',
			down = '<C-j>',
			up = '<C-k>',
		}
		})
	end,
	keys = {
		{ "<C-h>", mode = { "n", "v" } },
		{ "<C-j>", mode = { "n", "v" } },
		{ "<C-k>", mode = { "n", "v" } },
		{ "<C-l>", mode = { "n", "v" } },
	},
}
