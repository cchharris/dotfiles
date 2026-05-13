-- Pin frequently-accessed files per-project; jump to slots 1-5 with <leader>1..5.
return {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    event = 'VeryLazy',
    config = function()
        local harpoon = require('harpoon')
        harpoon:setup()

        vim.keymap.set('n', '<leader>m', function() harpoon:list():add() end,
            { desc = '<Harpoon>  Add file' })
        vim.keymap.set('n', '<leader>M', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
            { desc = '<Harpoon>  Toggle menu' })

        for i = 1, 5 do
            vim.keymap.set('n', '<leader>' .. i, function() harpoon:list():select(i) end,
                { desc = '<Harpoon>  Goto file ' .. i })
        end

        vim.keymap.set('n', '<leader>[', function() harpoon:list():prev() end,
            { desc = '<Harpoon>  Previous mark' })
        vim.keymap.set('n', '<leader>]', function() harpoon:list():next() end,
            { desc = '<Harpoon>  Next mark' })
    end,
}
