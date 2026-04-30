local M = {}

local _restore_cmd = nil

function M.toggle_full()
    local Terminal = require("sidekick.cli.terminal")

    -- Clear stale restore state if sidekick was closed while maximized
    if _restore_cmd then
        local any_open = false
        for _, t in pairs(Terminal.terminals) do
            if t:is_open() then any_open = true; break end
        end
        if not any_open then _restore_cmd = nil end
    end

    -- When on the dashboard, navigate to an empty buffer first so the
    -- pane-2 terminal sections don't render over the sidekick window.
    if vim.bo.filetype == "snacks_dashboard" then
        vim.cmd("enew")
    end

    local term
    for _, t in pairs(Terminal.terminals) do
        if t:is_open() then term = t; break end
    end

    if not term then
        require("sidekick.cli").toggle({ name = "claude", focus = true })
        vim.schedule(function()
            for _, t in pairs(Terminal.terminals) do
                if t:is_open() then
                    _restore_cmd = vim.fn.winrestcmd()
                    vim.api.nvim_set_current_win(t.win)
                    vim.cmd("wincmd |")
                    vim.cmd("wincmd _")
                    break
                end
            end
        end)
        return
    end

    if _restore_cmd then
        vim.cmd(_restore_cmd)
        _restore_cmd = nil
    else
        _restore_cmd = vim.fn.winrestcmd()
        vim.api.nvim_set_current_win(term.win)
        vim.cmd("wincmd |")
        vim.cmd("wincmd _")
    end
end

return M
