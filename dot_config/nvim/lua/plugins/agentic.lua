-- Multi-agent chat via the Agent Client Protocol. Sits alongside sidekick.nvim
-- (which keeps Claude Code + NES). Use agentic for Codex / Gemini / OpenCode /
-- Cline / Goose / Cursor agent etc. Each Neovim tab can hold an independent session.
--
-- Each provider's CLI must be installed separately (the plugin shells out to it).
-- Belt-and-suspenders: in the Agentic input buffer, force <Space>/<\> to insert
-- literally in insert mode with nowait, so any future plugin that registers an
-- insert-mode <leader>/<localleader> map won't cause typing delays or stray
-- command triggers here. Normal/visual mode are left alone so the user can
-- still use <leader> commands after pressing Esc.
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'AgenticInput',
    callback = function(args)
        local opts = { buffer = args.buf, nowait = true, silent = true }
        vim.keymap.set('i', '<Space>', '<Space>', opts)
        vim.keymap.set('i', '\\', '\\', opts)
    end,
})

return {
	"carlos-algms/agentic.nvim",
	cmd = { "Agentic" },
	---@type agentic.PartialUserConfig
	opts = {
		provider = "claude-agent-acp",
		acp_providers = {
			["claude-agent-acp"] = {},
			["codex-acp"] = {},
			["gemini-acp"] = {},
			["opencode-acp"] = {},
		},
	},
	-- Note: do not register these in insert mode. They'd be the only
	-- <leader>-prefixed insert-mode maps in this config and would cause every
	-- <Space> in insert mode (everywhere, not just Agentic buffers) to wait
	-- timeoutlen before being inserted.
	keys = {
		{
			"<leader>aa",
			function()
				require("agentic").toggle()
			end,
			mode = { "n", "v" },
			desc = "<Agentic>  Toggle chat",
		},
		{
			"<leader>an",
			function()
				require("agentic").new_session()
			end,
			mode = { "n", "v" },
			desc = "<Agentic>  New session (pick provider)",
		},
		{
			"<leader>aS",
			function()
				require("agentic").add_selection_or_file_to_context()
			end,
			mode = { "n", "v" },
			desc = "<Agentic>  Add selection/file to context",
		},
	},
}
