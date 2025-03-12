
return {
"ruifm/gitlinker.nvim",

  dependencies = {
    "nvim-lua/plenary.nvim",
	},
	opts = { mappings = nil },
	keys = {
		{ '<leader>gb', '<cmd>lua require"gitlinker".get_buf_range_url("n", {action_callback = require"gitlinker.actions".open_in_browser})<cr>', mode = 'n', desc = '<GitLinker> Open in browser' },
		{ '<leader>gb', '<cmd>lua require"gitlinker".get_buf_range_url("v", {action_callback = require"gitlinker.actions".open_in_browser})<cr>', mode = 'v', desc = '<GitLinker> Open in browser' },
		{ '<leader>gy', '<cmd>lua require"gitlinker".get_buf_range_url("n")<cr>', mode = 'n', desc = '<GitLinker> Copy url to clipboard' },
		{ '<leader>gy', '<cmd>lua require"gitlinker".get_buf_range_url("v")<cr>', mode = 'v', desc = '<GitLinker> Copy url to clipboard' },
	}
}
