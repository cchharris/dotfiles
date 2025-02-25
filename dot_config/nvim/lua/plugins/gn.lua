return {
	'https://gn.googlesource.com/gn',
	config = function(plugin)
		vim.opt.rtp:append(plugin.dir .. 'misc/vim')
	end
}
