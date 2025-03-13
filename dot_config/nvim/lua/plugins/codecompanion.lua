return  {
  "olimorris/codecompanion.nvim",
  config = true,
  event = { "BufRead", "BufNewFile" },
	cmd = {
		'CodeCompanion',
		'CodeCompanionCmd',
		'CodeCompanionChat',
		'CodeCompanionActions',
	},
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
	"hrsh7th/nvim-cmp",
  },
  opts = {
    strategies = {
      -- Change the default chat adapter
      chat = {
        adapter = "copilot",
      },
    },
    opts = {
      -- Set debug logging
      log_level = "DEBUG",
    },
  },
}
