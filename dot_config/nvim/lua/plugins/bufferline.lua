return {
	'akinsho/bufferline.nvim',
	version="*",
	  event = { "BufRead", "BufNewFile" },
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
