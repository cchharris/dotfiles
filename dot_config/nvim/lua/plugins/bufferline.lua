return {
	'akinsho/bufferline.nvim',
	version="*",
	dependencies='nvim-tree/nvim-web-devicons',
	opts = {},
	keys = {
		{
			'<leader>bp',
			function()
				require('bufferline').pick_buffer()
			end,
			desc = "<Bufferline> Pick buffer",
		},
	},
}
