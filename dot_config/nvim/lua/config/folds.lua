local M = {}

-- Optimized treesitter foldexpr for Neovim >= 0.10.0
function M.foldexpr()
    local buf = vim.api.nvim_get_current_buf()
    if vim.b[buf].ts_folds == nil then
        -- as long as we don't have a filetype, don't bother
        -- checking if treesitter is available (it won't)
        if vim.bo[buf].filetype == "" then
            return "0"
        end
        if vim.bo[buf].filetype:find("dashboard") then
            vim.b[buf].ts_folds = false
        else
            vim.b[buf].ts_folds = pcall(vim.treesitter.get_parser, buf)
        end
    end
    return vim.b[buf].ts_folds and vim.treesitter.foldexpr() or "0"
end

-- LSP foldexpr with fold level capped to indent level, to prevent
-- fold_line bars rendering over unindented text.
function M.lsp_foldexpr()
    local result = vim.lsp.foldexpr()
    local n = tonumber(result)
    if n and n > 1 then
        local sw = vim.bo.shiftwidth
        if sw > 0 then
            local max_level = math.floor(vim.fn.indent(vim.v.lnum) / sw) + 1
            if n > max_level then return tostring(max_level) end
        end
    end
    return result
end

return M
