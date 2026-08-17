-- roobert/action-hints.nvim is unmaintained (no commits since 2023) and calls
-- deprecated vim.lsp.buf_get_clients()/nvim_buf_get_option(). `build` re-patches
-- the vendored source after every install/update since upstream will never fix it.
local function patch_deprecated_api(plugin)
    local path = plugin.dir .. "/lua/action-hints/init.lua"
    local f = io.open(path, "r")
    if not f then return end
    local content = f:read("*a")
    f:close()

    local patched = content
        :gsub("vim%.lsp%.buf_get_clients%(%)", "vim.lsp.get_clients({ bufnr = 0 })")
        :gsub('vim%.api%.nvim_buf_get_option%(bufnr, "buftype"%)', 'vim.api.nvim_get_option_value("buftype", { buf = bufnr })')
        :gsub('vim%.api%.nvim_buf_get_option%(bufnr, "filetype"%)', 'vim.api.nvim_get_option_value("filetype", { buf = bufnr })')

    if patched ~= content then
        local out = assert(io.open(path, "w"))
        out:write(patched)
        out:close()
    end
end

return {
    "roobert/action-hints.nvim",
    event = "LspAttach",
    build = patch_deprecated_api,
    config = function()
        require('action-hints').setup({
            template = {
                definition = { text = " ⊛", color = "#add8e6" },
                references = { text = " ↱%s", color = "#ff6666" },
            },
            use_virtual_text = true,
        }
        )
    end
}
