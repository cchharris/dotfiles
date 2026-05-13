-- Auto-fix Python imports project-wide when a module file is renamed or moved.
return {
    'alexpasmantier/pymple.nvim',
    ft = 'python',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'MunifTanjim/nui.nvim',
        'stevearc/dressing.nvim',
    },
    build = ':PympleBuild',
    config = function()
        require('pymple').setup()
    end,
}
