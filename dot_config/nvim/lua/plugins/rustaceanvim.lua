vim.g.rustaceanvim = {
    server = {
        on_attach = function(client, bufnr)
        end,
    },
    default_settings = {
        ['rust-analyzer'] = {
            cargo = {
                targetDir = true,
            },
            check = {
                workspace = false,
            },
            cachePriming = {
                enable = false,
            },
        },
    },
    lsp = {
        load_vscode_settings = true,
    },
};

return {
    'mrcjkb/rustaceanvim',
    version = '^6', -- Recommended
    lazy = false,
    --dependencies = {
    --'nvim-neotest/neotest',  -- TestAdapter looks for 'neotest' being loaded
    --'mfussenegger/nvim-dap', -- Debugger looks for 'dap' being loaded
    --},
    --cmd = 'RustLsp',
    --event = { 'BufReadPre *.rs', 'BufNewFile *.rs', 'BufReadPre Cargo.toml', 'BufNewFile Cargo.toml' },
}
