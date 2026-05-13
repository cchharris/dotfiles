-- clangd-only features lspconfig doesn't expose: switch source/header,
-- AST view, memory-usage inlay, symbol-info, type-hierarchy.
-- inlay_hints / ast / memory_usage commands live on `:ClangdAST`, `:ClangdSwitchSourceHeader`, etc.
return {
    'p00f/clangd_extensions.nvim',
    ft = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
    opts = {
        inlay_hints = {
            -- Use native LSP inlay hints; clangd_extensions's own inlay hint
            -- implementation predates Neovim's built-in support and is now redundant.
            inline = false,
        },
        ast = {
            role_icons = {
                type       = "",
                declaration = "",
                expression = "",
                specifier  = "",
                statement  = "",
                ['template argument'] = "",
            },
            kind_icons = {
                Compound    = "",
                Recovery    = "",
                TranslationUnit = "",
                PackExpansion   = "",
                TemplateTypeParm = "",
                TemplateTemplateParm = "",
                TemplateParamObject = "",
            },
        },
    },
    keys = {
        {
            '<leader>ch',
            '<cmd>ClangdSwitchSourceHeader<cr>',
            ft = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
            desc = '<Clangd>  Switch source/header',
        },
        {
            '<leader>cA',
            '<cmd>ClangdAST<cr>',
            ft = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
            desc = '<Clangd>  AST view',
        },
        {
            '<leader>cM',
            '<cmd>ClangdMemoryUsage<cr>',
            ft = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
            desc = '<Clangd>  Memory usage',
        },
        {
            '<leader>cT',
            '<cmd>ClangdTypeHierarchy<cr>',
            ft = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
            desc = '<Clangd>  Type hierarchy',
        },
    },
}
