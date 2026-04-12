return {
	'https://gn.googlesource.com/gn',
	ft = { 'gn' },
	config = function(plugin)
		vim.opt.rtp:append(vim.fs.joinpath(plugin.dir, 'misc', 'vim'))
	end
}
