return {
	'ojroques/nvim-hardline',
	requires = {
	    'AlexvZyl/nordic.nvim',
	},
	config = function()
		require('hardline').setup({
			bufferline=false,
			theme='nordic',
		})
	end
}
