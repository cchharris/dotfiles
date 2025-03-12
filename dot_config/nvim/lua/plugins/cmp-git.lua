return {
    "petertriho/cmp-git",
    dependencies = { 'hrsh7th/nvim-cmp' },
	ft = { 'gitcommit', 'octo', 'NeogitCommitMessage' },
    config = function()
		table.insert(require('cmp').get_config().sources, { name = 'git' })
	end
}
