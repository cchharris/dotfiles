local dashboard = {
    { section = "header" },
    { icon = "󰍉 ", key = "f", desc = "Find File", action = ":lua require('telescope.builtin').fd()" },
    { icon = "󰈔 ", key = "n", desc = "New File", action = ":ene | startinsert" },
    { icon = "󰊄 ", key = "r", desc = "Find Text", action = ":lua require('telescope').extensions.live_grep_args.live_grep_args()" },
    { icon = "󰋚 ", key = "o", desc = "Recent Files", action = ":lua require('telescope.builtin').oldfiles()" },
    { icon = "󰒓 ", key = "c", desc = "Config", action = ":lua require('telescope.builtin').fd({cwd = vim.fn.stdpath('config')})" },
    { icon = "󰚝 ", key = "z", desc = "Chezmoi", action = ":lua require('telescope').extensions.chezmoi.find_files()" },
    { icon = "󰦛 ", key = "s", desc = "Restore Session", enabled = function() return require('auto-session')
        .session_exists_for_cwd() end, action = ":lua require('auto-session').restore_session()" },
    { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
    { icon = "󰈆 ", key = "q", desc = "Quit", action = ":qa" },
    { section = "startup" },
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

return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    config = function()
        require("snacks").setup({
            bigfile      = { enabled = true },
            bufdelete    = { enabled = true },
            dashboard    = { enabled = true, sections = dashboard, width = 120 },
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
