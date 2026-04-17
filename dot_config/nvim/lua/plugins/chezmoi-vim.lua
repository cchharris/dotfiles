return {
	'alker0/chezmoi.vim',
	cond = vim.fn.has('win32') == 1,
	event = "VeryLazy",
	init = function()
		vim.g['chezmoi#use_tmp_buffer'] = true
	end,
}
