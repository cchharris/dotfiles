return {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
        "mason-org/mason.nvim",
        { "neovim/nvim-lspconfig", dependencies = {
            { "antosha417/nvim-lsp-file-operations", config = true },
            { "folke/lazydev.nvim", ft = "lua", opts = {} },
            "b0o/schemastore.nvim",
            "saghen/blink.cmp",
        }},
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        require("mason").setup()

        -- On non-Windows, nix provides all LSP servers on PATH — Mason must not
        -- try to install them (pre-compiled binaries don't work on NixOS).
        local ensure_installed = vim.fn.has("win32") == 1 and {
            "bashls",        -- bash
            "buf_ls",        -- protobuf
            "clangd",        -- c, c++
            "cmake",         -- cmake
            "dockerls",      -- docker
            "html",          -- html
            "jsonls",        -- json
            "lua_ls",        -- lua
            "nil_ls",        -- nix
            "omnisharp",     -- c# (unity, .NET)
            "powershell_es", -- powershell
            "ruff",          -- python
            --"rust_analyzer", -- rust -- May conflict with rustaceanvim
            "starpls",
            "tailwindcss",   -- css
            "taplo",         -- toml
            "terraformls",   -- terraform
            "tsgo",          -- typescript, javascript
            "ty",            -- python
            "pyrefly",       -- python
            "vimls",         -- vimscript
            "yamlls",        -- yaml
            "zls",           -- zig
            --"harper_ls",   -- toml, typescript, rust, ruby, python, markdown, lua, javascript, java, C, C++, C#
        } or {}

        require("mason-lspconfig").setup({ ensure_installed = ensure_installed })

        local keymap = vim.keymap

        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(ev)
                local opts = { buffer = ev.buf, silent = true }

                if vim.lsp.inline_completion ~= nil then
                    vim.lsp.inline_completion.enable(true)
                end

                opts.desc = "Show LSP references"
                keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

                opts.desc = "Go to declaration"
                keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

                opts.desc = "Show LSP definitions"
                keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

                opts.desc = "Show LSP implementations"
                keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

                opts.desc = "Show LSP type definitions"
                keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

                -- Taken over by aznhe21/actions-preview.nvim
                -- opts.desc = "Show available code actions"
                -- keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

                opts.desc = "Smart rename"
                keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

                opts.desc = "Show buffer diagnostics"
                keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

                opts.desc = "Show line diagnostics"
                keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

                opts.desc = "Go to previous diagnostic"
                keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

                opts.desc = "Go to next diagnostic"
                keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

                opts.desc = "Show documentation for what is under cursor"
                keymap.set("n", "K", vim.lsp.buf.hover, opts)

                opts.desc = "Restart LSP"
                keymap.set("n", "<leader>rs", "<cmd>LspRestart<CR>", opts)
            end,
        })

        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup('lsp_attach_disable_ruff_hover', { clear = true }),
            callback = function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if client == nil then return end
                if client.name == 'ruff' then
                    client.server_capabilities.hoverProvider = false
                end
            end,
            desc = 'LSP: Disable hover capability for Ruff',
        })

        local capabilities = require('blink.cmp').get_lsp_capabilities(
            require('lsp-file-operations').default_capabilities()
        )
        capabilities.textDocument.completion.completionItem.snippetSupport = true
        capabilities.textDocument.foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true,
        }

        vim.lsp.inlay_hint.enable(true)

        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
        vim.diagnostic.config({
            float = { border = "rounded", prefix = "", header = "", severity_sort = true, source = true },
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = " ",
                    [vim.diagnostic.severity.WARN]  = " ",
                    [vim.diagnostic.severity.HINT]  = "󰠠 ",
                    [vim.diagnostic.severity.INFO]  = " ",
                },
            },
        })

        vim.lsp.config('*', { capabilities = capabilities })

        vim.lsp.config('html', {
            settings = {
                html = { format = { wrapLineLength = 0 } },
            },
        })

        vim.lsp.config('cssls', {
            settings = {
                css = { lint = { unknownAtRules = "ignore" } },
            },
        })

        vim.lsp.config('lua_ls', {
            settings = {
                Lua = {
                    diagnostics = { globals = { "vim" } },
                    completion = { callSnippet = "Replace" },
                },
            },
        })

        --rustacean takes over
        -- ['rust_analyzer'] = function() end,
    end
}
