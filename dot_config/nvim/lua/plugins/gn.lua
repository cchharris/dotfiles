return {
	'https://gn.googlesource.com/gn',
	ft = { 'gn' },
	config = function(plugin)
		vim.opt.rtp:append(plugin.dir .. 'misc/vim')
	end
}
