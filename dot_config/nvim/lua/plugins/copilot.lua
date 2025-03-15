return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
	opts = {
		-- suggestion = { enabled = false }, -- copilot cmp does this instead
		-- panel = { enabled = false }, -- copilot cmp does this instead
	suggestion = {
		auto_trigger = true,
		keymap = {
			accept="<tab>",
			accept_word="<c-space>",
			accept_line="<c-l>",
			next="<c-j>",
			prev="<c-k>",
		},
	}
	}
}
