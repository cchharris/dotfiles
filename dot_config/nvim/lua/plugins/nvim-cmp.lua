return {
  "hrsh7th/nvim-cmp",
  event = {"InsertEnter", "CmdlineEnter" },
  dependencies = {
    "hrsh7th/cmp-buffer", -- source text within current buffer
    --"hrsh7th/cmp-path", -- source filesystem paths
    "https://codeberg.org/FelipeLema/cmp-async-path", -- async path completion
    "hrsh7th/cmp-emoji", -- unicode emoji
    "hrsh7th/cmp-nvim-lsp", -- source for nvim lsp
    "hrsh7th/cmp-cmdline", -- source for cmdline
    "hrsh7th/cmp-nvim-lsp-signature-help", -- function signature help
    "neovim/nvim-lspconfig", -- enable LSP
    -- snippets
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      build = "make install_jsregexp",
    },
    "saadparwaiz1/cmp_luasnip", -- for autocompletion
    "rafamadriz/friendly-snippets", -- useful snippets
    "onsails/lspkind.nvim", -- vs-code like pictograms
    "luckasRanarison/tailwind-tools.nvim", -- tailwind
    "micangl/cmp-vimtex", -- tex
    -- "zbirenbaum/copilot-cmp", -- copilot
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    luasnip.config.set_config({
      -- enable autosnippets
      enable_autosnippets = true,
    })

    -- load vscode-style snippets
    require("luasnip.loaders.from_vscode").lazy_load({
      exclude = { "html" },
    })

    -- load custom snippets
    require("luasnip.loaders.from_lua").lazy_load({ paths = { "./lua/luasnip/" } })

    -- use rounded box for tailwind colors
    require("tailwind-tools").setup({
      document_color = {
        inline_symbol = " ",
      },
    })

	-- Recommended by copilot-cmp
	-- local has_words_before = function()
	--   if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
	--   local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	--   return col ~= 0 and vim.api.nvim_buf_get_text(0, line-1, 0, line-1, col, {})[1]:match("^%s*$") == nil
	-- end
    cmp.setup({
      completion = {
        completeopt = "menu,menuone,preview,noselect",
      },
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-e>"] = cmp.mapping.abort(), -- close completion window
        ["<CR>"] = cmp.mapping.confirm({ select = true }), -- confirm with first item
        ["<Tab>"] = cmp.mapping(function(fallback)
			-- Turn this on if we want to use tab completion with copilot.cmp
			-- if cmp.visible() and has_words_before() then
			-- 	cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
			-- else
			if luasnip.locally_jumpable(1) then
				luasnip.jump(1)
			else
				fallback()
          end
        end, { "i", "n", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
			if luasnip.locally_jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
          end
        end, { "i", "n", "s" }),
      }),
      -- sources for autocompletion
      sources = cmp.config.sources({
        { name = "nvim_lsp" }, -- lsp
        { name = "nvim_lsp_signature_help" }, -- signature help
        -- { name = "copilot" }, -- copilot
        { name = "luasnip" }, -- snippets
        { name = "buffer" }, -- text within current buffer
        { name = "async_path" }, -- filesystem paths
        { name = "vimtex" }, -- tex
        { name = "crates" }, -- rust crates
        { name = "emoji" }, -- unicode emoji
        { name = "octo" }, -- octo
      }),
		sorting = {
			priority_weight = 2,
			comparators = {
			  -- require("copilot_cmp.comparators").prioritize,

			  -- Below is the default comparitor list and order for nvim-cmp
			  cmp.config.compare.offset,
			  -- cmp.config.compare.scopes, --this is commented in nvim-cmp too
			  cmp.config.compare.exact,
			  cmp.config.compare.score,
			  cmp.config.compare.recently_used,
			  cmp.config.compare.locality,
			  cmp.config.compare.kind,
			  cmp.config.compare.sort_text,
			  cmp.config.compare.length,
			  cmp.config.compare.order,
			},
		},
      -- configure lspkind for vscode-like pictograms in completion menu
      formatting = {
        format = require("lspkind").cmp_format({
          maxwidth = 50,
          ellipsis_char = "...",
          before = require("tailwind-tools.cmp").lspkind_format,
          symbol_map = { Copilot = "" },
        }),
      },
    })
  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    }),
    matching = { disallow_symbol_nonprefix_matching = false }
  })
  end,
}
