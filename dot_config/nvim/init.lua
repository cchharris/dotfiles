require("config.lazy")

--vim.cmd [[colorscheme habamax]]
vim.cmd [[set relativenumber]]
vim.cmd [[set number]]
vim.cmd [[set cursorline]]
vim.cmd [[set expandtab]]
vim.cmd [[set tabstop=4]]
vim.cmd [[set shiftwidth=4]]
vim.cmd [[set clipboard+=unnamedplus]]

vim.o.foldcolumn = '1'
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true
--vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
--
vim.o.foldmethod = 'expr'


-- optimized treesitter foldexpr for Neovim >= 0.10.0
function Foldexpr()
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

-- Default to treesitter folding
if vim.fn.has("nvim-0.10") == 1 then
    vim.opt.foldexpr = "v:lua.Foldexpr()"
else
    vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
end

-- Prefer LSP folding if client supports it
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client:supports_method('textDocument/foldingRange') then
            local win = vim.api.nvim_get_current_win()
            vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
        end
    end,
})

vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
