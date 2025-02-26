return {
 "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason.nvim",
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/lazydev.nvim", ft = "lua", opts = {} },
    "b0o/schemastore.nvim",
  },
  config = function()
    local keymap = vim.keymap

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(ev)
        -- buffer local mappings
        local opts = { buffer = ev.buf, silent = true }

        -- set keybinds
        -- show definition, references
        opts.desc = "Show LSP references"
        keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

        -- go to declaration
        opts.desc = "Go to declaration"
        keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

        -- show lsp definitions
        opts.desc = "Show LSP definitions"
        keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

        -- show lsp implementations
        opts.desc = "Show LSP implementations"
        keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

        -- show lsp type definitions
        opts.desc = "Show LSP type definitions"
        keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

        -- see available code actions
        opts.desc = "Show available code actions"
        keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

        -- smart rename
        opts.desc = "Smart rename"
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

        -- show diagnostics
        opts.desc = "Show buffer diagnostics"
        keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

        -- show diagnostics for line
        opts.desc = "Show line diagnostics"
        keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

        -- jump to previous diagnostic in buffer
        opts.desc = "Go to previous diagnostic"
        keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

        -- jump to next diagnostic in buffer
        opts.desc = "Go to next diagnostic"
        keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

        -- show documentation for what is under cursor
        opts.desc = "Show documentation for what is under cursor"
        keymap.set("n", "K", vim.lsp.buf.hover, opts)

        -- mapping to restart lsp if necessary
        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>rs", "<cmd>LspRestart<CR>", opts)
      end,
    })
    vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup('lsp_attach_disable_ruff_hover', { clear = true }),
      callback = function(args)
	local client = vim.lsp.get_client_by_id(args.data.client_id)
	if client == nil then
		return
	end
	if client.name == 'ruff' then
		--Disable hover for ruff
		client.server_capabilities.hoverProvider = false
	end
      end,
	desc = 'LSP: Disable hover capability for Ruff',
    })

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    -- enable snippet
    capabilities.textDocument.completion.completionItem.snippetSupport = true

    -- change diagnostic symbols in the sign column (gutter)
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- enable inlay hint
    vim.lsp.inlay_hint.enable(true, { 0 })

    -- enable borders
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
    vim.diagnostic.config({
      float = { border = "rounded", prefix = "", header = "", severity_sort = true, source = true },
    })

    local lspconfig = require("lspconfig")
    require("mason-lspconfig").setup_handlers({
      -- default handler for installed server
      function(server_name)
        lspconfig[server_name].setup({
          capabilities = capabilities,
        })
      end,
      ["html"] = function()
        -- configure html language server
        lspconfig["html"].setup({
          capabilities = capabilities,
          settings = {
            html = {
              format = {
                wrapLineLength = 0,
              },
            },
          },
        })
      end,
      ["cssls"] = function()
        -- configure css langauge server (and ignore unknownAtRules)
        lspconfig["cssls"].setup({
          capabilities = capabilities,
          settings = {
            css = {
              lint = {
                unknownAtRules = "ignore",
              },
            },
          },
        })
      end,
      ["lua_ls"] = function()
        -- configure lua server (with special settings)
        lspconfig["lua_ls"].setup({
          capabilities = capabilities,
          settings = {
            Lua = {
              -- make the language server recognize "vim" global
              diagnostics = {
                globals = { "vim" },
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        })
      end,
	["bashls"] = function()
	-- configure bash
	 lspconfig["bashls"].setup({
		capabilities = capabilities, 
	})
	end,
	["clangd"] = function()
	-- configure C/C++
	 lspconfig["clangd"].setup({
		capabilities = capabilities
	})
	end,
	["cmake"] = function()
	-- configure cmake
	 lspconfig["cmake"].setup({capabilities = capabilities})
	end,
	["dockerls"] = function()
	-- configure docker
	 lspconfig["dockerls"].setup({capabilities=capabilities})
	end,
	["ts_ls"] = function()
	-- configure typescript
	 lspconfig["ts_ls"].setup({capabilities=capabilities})
	end,
	["pyright"] = function()
	-- configure python
	 lspconfig["pyright"].setup({capabilities=capabilities})
	end,
	["ruff"] = function()
	-- configure python
	 lspconfig["ruff"].setup({capabilities=capabilities})
	end,
	["rust_analyzer"] = function()
	-- configure rust
	 lspconfig["rust_analyzer"].setup({capabilities=capabilities})
	end,
	["bzl"] = function()
	-- configure bazel
	 lspconfig["bzl"].setup({capabilities=capabilities})
	end,
	["terraformls"] = function()
	-- configure terraform
	 lspconfig["terraformls"].setup({capabilities=capabilities})
	end,
	["tflint"] = function()
	-- configure terraform
	 lspconfig["tflint"].setup({capabilities=capabilities})
	end,
	["harper_ls"] = function()
	-- configure 
	 lspconfig["harper_ls"].setup({capabilities=capabilities})
	end,
	["vimls"] = function()
	-- configure vimscript
	 lspconfig["vimls"].setup({capabilities=capabilities})
	end,
    })
  end,
}
