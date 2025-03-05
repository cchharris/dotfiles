return {
	'akinsho/bufferline.nvim',
	version="*",
	dependencies='nvim-tree/nvim-web-devicons',
	config = function()
		require("bufferline").setup({ })
	end,
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
