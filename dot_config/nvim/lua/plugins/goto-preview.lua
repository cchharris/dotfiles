return {
  "rmagatti/goto-preview",
  dependencies = { "rmagatti/logger.nvim" },
  event = "BufEnter",
  opts = {},
    keys = {
        {
            'gpd',
            function()
                require('goto-preview').goto_preview_declaration()
            end,
            desc = 'Preview declaration',
        },
        {
            'gpt',
            function()
                require('goto-preview').goto_preview_type_definition()
            end,
            desc = 'Preview type definition',
        },
        {
            'gpi',
            function()
                require('goto-preview').goto_preview_implementation()
            end,
            desc = 'Preview implementation',
        },
        {
            'gpD',
            function()
                require('goto-preview').goto_preview_declaration()
            end,
            desc = 'Preview declaration',
        },
        {
            'gP',
            function()
                require('goto-preview').close_all_win()
            end,
            desc = 'Close all preview windows',
        },
        {
            'gpr',
            function()
                require('goto-preview').goto_preview_references()
            end,
            desc = 'Preview references',
        },
    },
}
