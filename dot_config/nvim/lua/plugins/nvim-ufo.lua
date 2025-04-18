return {
    'kevinhwang91/nvim-ufo',
    dependencies = {
        'kevinhwang91/promise-async',
    },
    lazy = false,
    init = function()
        vim.o.foldcolumn = '1'
        vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true
        --vim.o.fillchars = [[eob: ,fold:,foldopen:,foldsep: ,foldclose:]]
    end,

    opts = {
        provider_selector = function(bufnr, filetype, buftype)
            return { 'lsp', 'indent' }
        end,
    },
    keys = {
        {
            'zR', function() require('ufo').openAllFolds() end, mode = 'n', desc = ' Open all folds',
        },
        {
            'zM', function() require('ufo').closeAllFolds() end, mode = 'n', desc = ' Close all folds',
        },
    },
}
