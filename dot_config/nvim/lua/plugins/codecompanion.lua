-- Local LLM coding assistant via Ollama (qwen3-coder-32k:30b).
-- Sits alongside sidekick.nvim (Claude Code) and agentic.nvim (ACP agents).
return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
	opts = {
		adapters = {
			http = {
				ollama = function()
					return require("codecompanion.adapters").extend("ollama", {
						schema = {
							model = {
								default = "qwen3-coder-32k:30b",
							},
							num_ctx = {
								default = 32768,
							},
						},
					})
				end,
			},
		},
		strategies = {
			chat = { adapter = "ollama" },
			inline = { adapter = "ollama" },
		},
	},
	keys = {
		{
			"<leader>oc",
			"<cmd>CodeCompanionChat Toggle<cr>",
			mode = { "n", "v" },
			desc = "<CodeCompanion>  Toggle chat",
		},
		{
			"<leader>oa",
			"<cmd>CodeCompanionActions<cr>",
			mode = { "n", "v" },
			desc = "<CodeCompanion>  Action palette",
		},
		{
			"<leader>oe",
			"<cmd>CodeCompanion<cr>",
			mode = { "v" },
			desc = "<CodeCompanion>  Inline edit selection",
		},
	},
}
