return {
"lewis6991/gitsigns.nvim",
event = { 'BufNewFile', 'BufReadPost' },
cmd = { 'Gitsigns' },
opts = {
		current_line_blame = true,
		current_line_blame_opts = {
			virt_text = true,
			virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
			delay = 1000,
		},
		numhl=true,
	},
keys = {
		{
			"]g",
			"<cmd>Gitsigns next_hunk<cr>",
			desc = " Go to next git hunk"
		},
		{
			"[g",
			"<cmd>Gitsigns prev_hunk<cr>",
			desc = " Go to previous git hunk"
		},
	}
}
