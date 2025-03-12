return {
    's1n7ax/nvim-window-picker',
    name = 'window-picker',
    version = '2.*',
	opts = {},
	keys = {
		{
			'<leader>wp',
			function()
				local window = require('window-picker').pick_window({hint='floating-big-letter', show_prompt=false})
				if window then
					vim.api.nvim_set_current_win(window)
				end
			end,
			desc = "<WindowPicker> Pick window",
		},
	}
}
