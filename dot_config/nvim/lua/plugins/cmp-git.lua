return {
    "petertriho/cmp-git",
    dependencies = { 'hrsh7th/nvim-cmp' },
    opts = {
        -- options go here
    },
    init = function()
	local cmp = require('cmp')
        cmp.setup.filetype('gitcommit', {
		sources = cmp.config.sources({
			{ name = 'git'},
		}, {
			{ name = 'buffer'},
		})
	})
	require('cmp_git').setup({})
    end
}
