
-- Taken entirely from https://github.com/rcarriga/nvim-notify/blob/22f29093eae7785773ee9d543f8750348b1a195c/lua/notify/stages/slide.lua
local borderless_slide = function(direction)
  return {
    function(state)
       local stages_util = require("notify.stages.util")
      local next_height = state.message.height
      local next_row = stages_util.available_slot(state.open_windows, next_height, direction)
      if not next_row then
        return nil
      end
      return {
        relative = "editor",
        anchor = "NE",
        width = 1,
        height = state.message.height,
        col = vim.opt.columns:get(),
        row = next_row,
        border = "none",
        style = "minimal",
      }
    end,
    function(state)
      return {
        width = { state.message.width, frequency = 2 },
        col = { vim.opt.columns:get() },
      }
    end,
    function()
      return {
        col = { vim.opt.columns:get() },
        time = true,
      }
    end,
    function()
      return {
        width = {
          1,
          frequency = 2.5,
          damping = 0.9,
          complete = function(cur_width)
            return cur_width < 2
          end,
        },
        col = { vim.opt.columns:get() },
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
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false, -- add a border to hover docs and signature help
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
        { "rcarriga/nvim-notify", opts = {render = 'compact', stages = borderless_slide("top_down"), fps = 60}, },
    }
}
