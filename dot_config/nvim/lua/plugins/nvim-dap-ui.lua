return {
    "rcarriga/nvim-dap-ui",
    lazy = true, -- loaded as a dependency of nvim-dap
    dependencies = {
        "mfussenegger/nvim-dap",
        "nvim-neotest/nvim-nio",
    },
    opts = {},
}
