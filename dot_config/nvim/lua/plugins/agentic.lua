-- Multi-agent chat via the Agent Client Protocol. Sits alongside sidekick.nvim
-- (which keeps Claude Code + NES). Use agentic for Codex / Gemini / OpenCode /
-- Cline / Goose / Cursor agent etc. Each Neovim tab can hold an independent session.
--
-- Each provider's CLI must be installed separately (the plugin shells out to it).
return {
    'carlos-algms/agentic.nvim',
    cmd = { 'Agentic' },
    ---@type agentic.PartialUserConfig
    opts = {
        provider = 'claude-agent-acp',
        acp_providers = {
            ['claude-agent-acp'] = {},
            ['codex-acp']        = {},
            ['gemini-acp']       = {},
            ['opencode-acp']     = {},
        },
    },
    keys = {
        {
            '<leader>aa',
            function() require('agentic').toggle() end,
            mode = { 'n', 'v', 'i' },
            desc = '<Agentic>  Toggle chat',
        },
        {
            '<leader>an',
            function() require('agentic').new_session() end,
            mode = { 'n', 'v' },
            desc = '<Agentic>  New session (pick provider)',
        },
        {
            '<leader>aS',
            function() require('agentic').add_selection_or_file_to_context() end,
            mode = { 'n', 'v' },
            desc = '<Agentic>  Add selection/file to context',
        },
    },
}
