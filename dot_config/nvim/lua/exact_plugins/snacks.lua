local sections = {
    { section = "header" },
    { pane = 1, icon = "󰍉 ", key = "f", desc = "Find File",       action = ":lua require('telescope.builtin').fd()" },
    { pane = 1, icon = "󰈔 ", key = "n", desc = "New File",        action = ":ene | startinsert" },
    { pane = 1, icon = "󰊄 ", key = "r", desc = "Find Text",       action = ":lua require('telescope').extensions.live_grep_args.live_grep_args()" },
    { pane = 1, icon = "󰋚 ", key = "o", desc = "Recent Files",    action = ":lua require('telescope.builtin').oldfiles()" },
    { pane = 1, icon = "󰒓 ", key = "c", desc = "Config",          action = ":lua require('telescope.builtin').fd({cwd = vim.fn.stdpath('config')})" },
    { pane = 1, icon = "󰚝 ", key = "z", desc = "Chezmoi",         action = ":lua require('telescope').extensions.chezmoi.find_files()" },
    { pane = 1, icon = "󰦛 ", key = "s", desc = "Restore Session", action = ":lua require('auto-session').restore_session()",
      enabled = function() return require('auto-session').session_exists_for_cwd() end },
    { pane = 1, icon = "󰒲 ", key = "L", desc = "Lazy",            action = ":Lazy", enabled = package.loaded.lazy ~= nil },
    { pane = 1, icon = "󰈆 ", key = "q", desc = "Quit",            action = ":qa" },
    { pane = 1, section = "startup" },
    function()
        return {
            {
                pane = 2,
                icon = "󰘛 ",
                title = "My Open PRs",
                section = "terminal",
                cmd = "gh search prs --author @me --state open --limit 8 2>/dev/null || echo '  (none)'",
                key = "P",
                action = function()
                    vim.fn.jobstart("gh search prs --author @me --state open --web", { detach = true })
                end,
                height = 10,
                padding = 1,
                ttl = 300,
                indent = 3,
            },
            {
                pane = 2,
                icon = "󰀄 ",
                title = "Involves @me",
                section = "terminal",
                cmd = "gh search prs --involves @me --state open --limit 8 2>/dev/null || echo '  (none)'",
                key = "I",
                action = function()
                    vim.fn.jobstart("gh search prs --involves @me --state open --web", { detach = true })
                end,
                height = 10,
                padding = 1,
                ttl = 300,
                indent = 3,
            },
            {
                pane = 2,
                icon = " ",
                title = "Git Status",
                section = "terminal",
                cmd = "git --no-pager diff --stat -B -M -C",
                key = "g",
                action = function()
                    Snacks.lazygit()
                end,
                height = 10,
                padding = 1,
                ttl = 5 * 60,
                indent = 3,
                enabled = function() return Snacks.git.get_root() ~= nil end,
            },
        }
    end,
}

return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    config = function()
        require("snacks").setup({
            bigfile      = { enabled = true },
            bufdelete    = { enabled = true },
            dashboard    = { enabled = true, sections = sections, width = 120 },
            explorer     = { enabled = true },
            indent       = { enabled = false },
            input        = { enabled = true },
            lazygit      = { enabled = true },
            notifier     = { enabled = false },
            picker       = { enabled = true },
            quickfile    = { enabled = true },
            scope        = { enabled = true },
            scroll       = { enabled = true },
            statuscolumn = { enabled = true, right = { "git" } },
            terminal     = { enabled = false },
            words        = { enabled = true },
        })
    end,
}
