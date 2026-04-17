return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim", -- Still necessary ?
        'nvim-neotest/neotest-jest',
        'stevearc/overseer.nvim',
        'nvim-neotest/neotest-python',
    },
    cmd = 'Neotest',
    -- Indexing tests can take awhile, we should start before we explicitly request it
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
        require("neotest").setup({
            ---@diagnostic disable-next-line: missing-fields
            consumers = {
                overseer = require('neotest.consumers.overseer'),
            },
            ---@diagnostic disable-next-line: missing-fields
            adapters = {
                require('rustaceanvim.neotest'),
                require('neotest-jest')({
                    jestCommand = "npm test --",
                    jestConfigFile = "jest.config.js",
                    env = { CI = true },
                    cwd = function(path)
                        return vim.fn.getcwd()
                    end,
                }),
                require('neotest-python'),
                --require('neotest-elixir'),
                --require('neotest-deno'),
            },
            ---@diagnostic disable-next-line: missing-fields
            discovery = {
                enabled = true,
                concurrent = true,
            },
        })
    end,
    keys = {
        {
            "<leader>tn",
            function()
                require("neotest").run.run()
            end,
            desc = "<Neotest> 󰙨 Run nearest test",
        },
        {
            "<leader>tf",
            function()
                require("neotest").run.run(vim.fn.expand("%"))
            end,
            desc = "<Neotest> 󰙨 Run test file",
        },
        {
            "<leader>ts",
            function()
                require("neotest").summary.toggle()
            end,
            desc = "<Neotest> 󰙨 Toggle test summary",
        },
        {
            "<leader>tc",
            function()
                require("neotest").run.stop()
            end,
            desc = "<Neotest> 󰤒 Stop test run",
        },
        {
            "<leader>ta",
            function()
                require("neotest").run.attach()
            end,
            desc = "<Neotest> 󰙨 Run and attach to test",
        },
    }

}
