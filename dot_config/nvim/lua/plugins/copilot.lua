return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
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
})
  end,
}
