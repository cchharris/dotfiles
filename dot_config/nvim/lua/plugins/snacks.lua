local dashboard = {  
	  { section = "header" },
		{ icon = " ", key = "f", desc = "Find File", action = ":lua require('telescope.builtin').fd()" },
      { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
      { icon = " ", key = "g", desc = "Find Text", action = ":lua require('telescope').extensions.live_grep_args.live_grep_args()" },
      { icon = " ", key = "r", desc = "Recent Files", action = ":lua require('telescope.builtin').oldfiles()" },
      { icon = " ", key = "c", desc = "Config", action = ":lua require('telescope.builtin').fd({cwd = vim.fn.stdpath('config')})" },
      { icon = " ", key = "C", desc = "Chezmoi", action = ":lua require('telescope').extensions.chezmoi.find_files()" },
      { icon = " ", key = "s", desc = "Restore Session", enabled = function() return require('auto-session').session_exists_for_cwd() end, action = ":lua require('auto-session').RestoreSession()" },
      { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
      { icon = " ", key = "q", desc = "Quit", action = ":qa" },
}


return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
	-- dependencies = {
	--   'rmagatti/auto-session',
	-- },
  ---@type snacks.Config
  opts = {
    -- Your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    bigfile = { enabled = true },
	bufdelete = { enabled = true},
    dashboard = { enabled = true, sections = dashboard },
    explorer = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
	lazygit = { enabled = true },
    notifier = { enabled = true },
    picker = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    terminal = { enabled = true },
    words = { enabled = true },
  }
}
