return {
    's1n7ax/nvim-window-picker',
    name = 'window-picker',
    version = '2.*',
	opts = {
		filter_rules = {
			-- filter using buffer options
			bo = {
				-- if the file type is in this list it will be ignored
				filetype = {'NvimTree', 'neo-tree', 'notify', 'quickfix', 'neominimap'},
				-- if the buffer type is in this list it will be ignored
				buftype = {'terminal'},
			},
		},
	},
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
