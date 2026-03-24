
return {
	"linrongbin16/gitlinker.nvim",
	 cmd = "GitLink",
	opts = {},
	keys = {
		{ '<leader>go', '<cmd>GitLink!<cr>', mode = {'n', 'v' }, desc = '<GitLinker> Open in browser' },
		{ '<leader>gO', '<cmd>GitLink! default_branch<cr>', mode = {'n', 'v'}, desc = '<GitLinker> Open <main> url in browser' },
		{ '<leader>gy', '<cmd>GitLink<cr>', mode = {'n', 'v'}, desc = '<GitLinker> Copy url to clipboard' },
		{ '<leader>gY', '<cmd>GitLink default_branch<cr>', mode = {'n', 'v'}, desc = '<GitLinker> Copy <main> url to clipboard' },
	}
}
