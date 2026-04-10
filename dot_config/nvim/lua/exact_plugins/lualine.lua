local function neotest()
    if package.loaded["neotest"] == nil then
        return ''
    end
    local n = require("neotest")
    local ids = n.state.adapter_ids()
    local counts = {
        total = 0,
        passed = 0,
        failed = 0,
        skipped = 0,
        running = 0,
    }
    local icons = {
        total = '󰙨',
        passed = '󰄲',
        failed = '󱈸',
        skipped = '󰤒',
        running = '󰜎',
    }
    for _, id in ipairs(ids) do
        local status = n.state.status_counts(id, { buffer = vim.api.nvim_get_current_buf() })
        if status then
            counts.total = counts.total + (status.total or 0)
            counts.passed = counts.passed + (status.passed or 0)
            counts.failed = counts.failed + (status.failed or 0)
            counts.skipped = counts.skipped + (status.skipped or 0)
            counts.running = counts.running + (status.running or 0)
        end
    end

    counts.total = counts.total - (counts.passed + counts.failed + counts.skipped + counts.running)
    local result = {}
    for status, count in pairs(counts) do
        if count > 0 then
            table.insert(result, icons[status] .. ' ' .. count)
        end
    end
    return table.concat(result, ' ')
end

local function recordingStatus()
    if package.loaded["recorder"] == nil then
        return ''
    end
    return require("recorder").recordingStatus()
end

local function displaySlots()
    if package.loaded["recorder"] == nil then
        return ''
    end
    return require("recorder").displaySlots()
end

local function sidekick()
    if package.loaded["sidekick"] == nil then
        return ''
    end
    local status = require("sidekick.status")
    local parts = {}
    local lsp = status.get()
    if lsp then
        local kind_icons = { Normal = '', Error = '', Warning = '', Inactive = '󰒲' }
        local icon = lsp.busy and '' or (kind_icons[lsp.kind] or '')
        table.insert(parts, icon)
    end
    local sessions = status.cli()
    if #sessions > 0 then
        local tools = {}
        for _, s in ipairs(sessions) do
            table.insert(tools, s.tool)
        end
        table.insert(parts, '󱙋 ' .. table.concat(tools, ','))
    end
    return table.concat(parts, ' ')
end

return {
    'nvim-lualine/lualine.nvim',
    dependencies = {
        'nvim-tree/nvim-web-devicons',
        'AndreM222/copilot-lualine',
        'folke/sidekick.nvim',
    },
    opts = {
        sections = {
            lualine_a = { 'mode' },
            lualine_b = { 'branch', 'diff', 'diagnostics' },
            lualine_c = { { 'filename', path = 1 } },
            lualine_x = { 'searchcount', 'selectioncount', neotest, 'overseer', sidekick, { 'copilot', show_colors = true }, { 'lsp_status', ignore_lsp = { 'copilot' } }, 'encoding', 'fileformat', 'filetype' },
            lualine_y = { recordingStatus, 'progress' },
            lualine_z = { displaySlots, 'location' }
        },
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = { { 'filename', path = 1 } },
            lualine_x = { function() return require('action-hints').statusline() end, 'location' },
            lualine_y = {},
            lualine_z = {}
        },
    }
}
