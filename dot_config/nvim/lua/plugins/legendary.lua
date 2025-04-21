return {
    'mrjones2014/legendary.nvim',
    -- since legendary.nvim handles all your keymaps/commands,
    -- its recommended to load legendary.nvim before other plugins
    priority = 10000,
    lazy = false,
    -- sqlite is only needed if you want to use frecency sorting
    dependencies = { 'kkharji/sqlite.lua', module = 'sqlite' },
    opts = {
        extensions = {
            diffview = true,
            lazy_nvim = {
                auto_register = true,
            },
            which_key = {
                auto_register = true
            },
        },
        sort = {
            frecency = false,
        },
        -- Initial keymaps to bind, can also be a function that returns the list
        keymaps = {
            { '<leader>wh', "<C-w>h",         description = "Move to left window" },
            { '<leader>wj', "<C-w>j",         description = "Move to bottom window" },
            { '<leader>wk', "<C-w>k",         description = "Move to top window" },
            { '<leader>wl', "<C-w>l",         description = "Move to right window" },
            { ']b',         ':bnext<Cr>',     description = "Next buffer" },
            { '[b',         ':bprevious<Cr>', description = "Previous buffer" },
            { '<leader>/',
                function()
                    vim.api.nvim_command(':let @/ = ""')
                    require('neominimap').refresh()
                end
            }
        },
        -- Initial commands to bind, can also be a function that returns the list
        commands = {
            {
                ':Bd',
                function()
                    require('snacks').bufdelete()
                end,
                { desc = 'Smart Delete buffer' },
            },
            {
                ':ChezmoiPluginNew [file_name]',
                function(input)
                    local filename = ''
                    if input.fargs and input.fargs[1] then
                        filename = input.fargs[1]
                    else
                        filename = vim.fn.input("Plugin name: ")
                    end
                    local path = vim.fs.normalize(vim.fs.joinpath("~", ".local", "share", "chezmoi", 'dot_config', 'nvim',
                        'lua', 'plugins', filename))
                    vim.api.nvim_command(':e ' .. path)
                end,
                opts = { desc = "Create a new chezmoi plugin", nargs = '?' },
            },
        },
        -- Initial augroups/autocmds to bind, can also be a function that returns the list
        autocmds = {
            -- {
            -- 'BufWritePre',
            -- function(ev)
            --     local clients = vim.lsp.get_clients({ bufnr = ev.buf, method = 'textDocument/formatting' })
            --     if clients == nil or #clients == 0 then
            --         vim.notify('No LSP clients attached to buffer', vim.log.levels.TRACE,
            --             { title = 'LSP' })
            --         return
            --     end
            --     local function supportsFilter(client)
            --         return client.supports_method('textDocument/formatting', ev.buf)
            --     end
            --     vim.notify(
            --         'Formatting clients:' .. '\n' ..
            --         table.concat(vim.tbl_map(function(t) return '- ' .. t.name end, clients), '\n'),
            --         vim.log.levels.INFO, { title = 'LSP' })
            --     vim.lsp.buf.format({
            --         async = false,
            --         bufnr = ev.buf,
            --         filter = supportsFilter
            --     })
            --     vim.notify('Formatted buffer', vim.log.levels.INFO, { title = 'LSP' })
            -- end,
            -- description = 'Format on save'
            -- },
            {
                { "BufRead", "BufNewFile" },
                function(ev)
                    local bufnr = ev.buf
                    local edit_watch = function()
                        require("chezmoi.commands.__edit").watch(bufnr)
                    end
                    vim.schedule(edit_watch)
                end,
                opts = {
                    pattern = { vim.fs.normalize(vim.fs.joinpath("~", ".local", "share", "chezmoi", "*")) },
                },
            },
        },
        -- Initial functions to bind, can also be a function that returns the list
        funcs = {},
        -- Initial item groups to bind,
        -- note that item groups can also
        -- be under keymaps, commands, autocmds, or funcs;
        -- can also be a function that returns the list
        itemgroups = {},
        -- default opts to merge with the `opts` table
        -- of each individual item
        default_opts = {
            -- for example, { silent = true, remap = false }
            keymaps = { silent = true, noremap = true },
            -- for example, { args = '?', bang = true }
            commands = {},
            -- for example, { buf = 0, once = true }
            autocmds = {},
        },
    },
}
