return {
    ---@module "neominimap.config.meta"
    "Isrothy/neominimap.nvim",
    version = "v3.*.*",
    cond = not vim.g.vscode, -- Disable in VSCode
    lazy = false,            -- NOTE: NO NEED to Lazy load
    -- dependencies = {
    -- 	'nvim-treesitter/nvim-treesitter', -- Required for syntax highlighting
    -- 	'lewis6991/gitsigns.nvim', -- Optional: For git diff highlighting
    -- },
    -- Optional
    keys = {
        -- Global Minimap Controls
        { "<leader>nm",  "<cmd>Neominimap toggle<cr>",      desc = "<Neominimap> 󰍉 Toggle global minimap" },
        { "<leader>no",  "<cmd>Neominimap on<cr>",          desc = "<Neominimap> 󰍉 Enable global minimap" },
        { "<leader>nc",  "<cmd>Neominimap off<cr>",         desc = "<Neominimap> 󰍉 Disable global minimap" },
        { "<leader>nr",  "<cmd>Neominimap refresh<cr>",     desc = "<Neominimap> 󰍉 Refresh global minimap" },

        -- Window-Specific Minimap Controls
        { "<leader>nwt", "<cmd>Neominimap winToggle<cr>",   desc = "<Neominimap>  Toggle minimap for current window" },
        { "<leader>nwr", "<cmd>Neominimap winRefresh<cr>",  desc = "<Neominimap>  Refresh minimap for current window" },
        { "<leader>nwo", "<cmd>Neominimap winOn<cr>",       desc = "<Neominimap>  Enable minimap for current window" },
        { "<leader>nwc", "<cmd>Neominimap winOff<cr>",      desc = "<Neominimap>  Disable minimap for current window" },

        -- Tab-Specific Minimap Controls
        { "<leader>ntt", "<cmd>Neominimap tabToggle<cr>",   desc = "<Neominimap>  Toggle minimap for current tab" },
        { "<leader>ntr", "<cmd>Neominimap tabRefresh<cr>",  desc = "<Neominimap>  Refresh minimap for current tab" },
        { "<leader>nto", "<cmd>Neominimap tabOn<cr>",       desc = "<Neominimap>  Enable minimap for current tab" },
        { "<leader>ntc", "<cmd>Neominimap tabOff<cr>",      desc = "<Neominimap>  Disable minimap for current tab" },

        -- Buffer-Specific Minimap Controls
        { "<leader>nbt", "<cmd>Neominimap bufToggle<cr>",   desc = "<Neominimap>  Toggle minimap for current buffer" },
        { "<leader>nbr", "<cmd>Neominimap bufRefresh<cr>",  desc = "<Neominimap>  Refresh minimap for current buffer" },
        { "<leader>nbo", "<cmd>Neominimap bufOn<cr>",       desc = "<Neominimap>  Enable minimap for current buffer" },
        { "<leader>nbc", "<cmd>Neominimap bufOff<cr>",      desc = "<Neominimap>  Disable minimap for current buffer" },

        ---Focus Controls
        { "<leader>nf",  "<cmd>Neominimap focus<cr>",       desc = "<Neominimap>  Focus on minimap" },
        { "<leader>nu",  "<cmd>Neominimap unfocus<cr>",     desc = "<Neominimap>  Unfocus minimap" },
        { "<leader>ns",  "<cmd>Neominimap toggleFocus<cr>", desc = "<Neominimap>  Switch focus on minimap" },
    },
    init = function()
        -- The following options are recommended when layout == "float"
        vim.opt.wrap = false
        vim.opt.sidescrolloff = 36 -- Set a large value

        --- Put your configuration here
        ---@type Neominimap.UserConfig
        vim.g.neominimap = {
            auto_enable = true,
            float = {
                window_border = "none", -- Border style for the floating window
            },
            click = {
                enabled = true,
            },
            search = {
                enabled = true,
            },
        }
    end,
}
