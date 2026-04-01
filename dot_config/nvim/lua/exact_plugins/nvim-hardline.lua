return {
	'ojroques/nvim-hardline',
	lazy = true, -- conflicts with lualine; enable only if switching statuslines
	dependencies = {
	    'AlexvZyl/nordic.nvim',
	},
	opts = {
		bufferline=false,
		theme='nordic',
	}
}
