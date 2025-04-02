return  {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim", -- Still necessary ?
    "nvim-treesitter/nvim-treesitter",
	'nvim-neotest/neotest-jest',
	'nvim-neotest/neotest-python',
	'jfpedroza/neotest-elixir',
	'markemmons/neotest-deno',
    'mrcjkb/rustaceanvim',
  },
	event = 'VeryLazy',
	config = function()
		require("neotest").setup({
			adapters = {
				require('rustaceanvim.neotest'),
				require('neotest-jest')({
					jestCommand = "npm test --",
					jestConfigFile = "jest.config.js",
					env = { CI = true },
					cwd = function(path)
						return vim.fn.getcwd()
					end,
				}),
				require('neotest-python'),
				require('neotest-elixir'),
				require('neotest-deno'),
			},
		})
	end,
	keys = {
		{
			"<leader>tn",
			function()
				require("neotest").run.run()
			end,
			desc = "󰙨 Run Neotest",
		},
		{
			"<leader>tf",
			function()
				require("neotest").run.run(vim.fn.expand("%"))
			end,
			desc = "󰙨󰧮 Run Neotest File",
		},
		{
			"<leader>ts",
			function()
				require("neotest").summary.toggle()
			end,
			desc = "󰙨 Toggle Neotest Summary",
		},
		{
			"<leader>tc",
			function()
				require("neotest").run.stop()
			end,
			desc = "󰤒 Stop Neotest",
		},
		{
			"<leader>ta",
			function()
				require("neotest").run.attach()
			end,
			desc = "󰙨 Run and Attach Neotest",
		},
	}

}
