return {
    'saecki/crates.nvim',
    event = { "BufRead Cargo.toml" },
    opts = {
        lsp = {
            actions = true,
            enabled = true,
            completion = true,
            hover = true,
        },
    },
}
