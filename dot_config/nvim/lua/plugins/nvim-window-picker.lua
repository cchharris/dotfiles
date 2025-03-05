return {
    's1n7ax/nvim-window-picker',
    name = 'window-picker',
    event = 'VeryLazy',
    version = '2.*',
    config = function()
        require'window-picker'.setup()
    end,
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
