-- Taken entirely from https://github.com/rcarriga/nvim-notify/blob/master/lua/notify/stages/slide_out.lu
local borderless_slide_out = function(direction)
    return {
        function(state)
            local next_height = state.message.height
            local next_row = require('notify.stages.util').available_slot(state.open_windows, next_height, direction)
            if not next_row then
                return nil
            end
            return {
                relative = "editor",
                anchor = "NE",
                width = state.message.width,
                height = state.message.height,
                col = vim.opt.columns:get(),
                row = next_row,
                border = "none",
                style = "minimal",
            }
        end,
        function(state, win)
            return {
                col = vim.opt.columns:get(),
                time = true,
                row = require('notify.stages.util').slot_after_previous(win, state.open_windows, direction),
            }
        end,
        function(state, win)
            return {
                width = {
                    1,
                    frequency = 2.5,
                    damping = 0.9,
                    complete = function(cur_width)
                        return cur_width < 3
                    end,
                },
                col = { vim.opt.columns:get() },
                row = {
                    require('notify.stages.util').slot_after_previous(win, state.open_windows, direction),
                    frequency = 3,
                    complete = function()
                        return true
                    end,
                },
            }
        end,
    }
end

return {
    "folke/noice.nvim",
    event = "VeryLazy",
    cmd = { 'Noice' },
    opts = {
        lsp = {
            -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
            override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
                ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
            },
        },
        -- you can enable a preset for easier configuration
        presets = {
            bottom_search = true,         -- use a classic bottom cmdline for search
            command_palette = true,       -- position the cmdline and popupmenu together
            long_message_to_split = true, -- long messages will be sent to a split
            inc_rename = false,           -- enables an input dialog for inc-rename.nvim
            lsp_doc_border = false,       -- add a border to hover docs and signature help
        },
        routes = {
            {
                filter = {
                    event = 'msg_show',
                    kind = '',
                    find = 'written',
                },
                opts = { skip = true },
            },
        },
    },
    dependencies = {
        -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
        "MunifTanjim/nui.nvim",
        -- OPTIONAL:
        --   `nvim-notify` is only needed, if you want to use the notification view.
        --   If not available, we use `mini` as the fallback
        { "rcarriga/nvim-notify", opts = { render = 'compact', stages = borderless_slide_out("top_down"), fps = 30 }, },
    }
}
