-- Discord-internal clint integration for conform.nvim.
-- Loaded from the local Discord monorepo checkout by default.
-- To install from the private GitHub repo instead, comment out `dir` and
-- uncomment the repo name below.

local discord_root = vim.fs.root(vim.fn.getcwd(), { "clint.config.ts" })

return {
    -- "discord/discord-clint.nvim",
    name = "discord-clint.nvim",
    dir = discord_root and vim.fs.joinpath(discord_root, "misc", "users", "chrisharris", "discord-clint.nvim"),
    cond = discord_root ~= nil,
    config = function()
        -- `main` calls setup() which errors if missing; explicitly require instead.
        require("discord-clint")
    end,
}
