return {
    'L3MON4D3/LuaSnip',
    version = 'v2.*',
    build = "make install_jsregexp",
    dependencies = {
        'rafamadriz/friendly-snippets',
    },
    config = function()
        local ls = require('luasnip')
        require('luasnip.loaders.from_vscode').lazy_load()
        ls.filetype_extend("all", { "_" })
        require('luasnip.loaders.from_snipmate').lazy_load()
    end
}
