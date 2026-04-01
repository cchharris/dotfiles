return {
	'alker0/chezmoi.vim',
	event = "VeryLazy",
	init = function()
		vim.g['chezmoi#use_tmp_buffer'] = true
	end,
}
