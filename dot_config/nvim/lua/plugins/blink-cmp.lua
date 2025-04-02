return {
  'saghen/blink.cmp',
  -- optional: provides snippets for the snippet source
  dependencies = {
        'rafamadriz/friendly-snippets',
        'MahanRahmati/blink-nerdfont.nvim',
        'Kaiser-Yang/blink-cmp-git',
        'Kaiser-Yang/blink-cmp-avante',
        'mikavilpas/blink-ripgrep.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        'L3MON4D3/LuaSnip', version = 'v2.*',
        'onsails/lspkind.nvim',
    },

  -- use a release tag to download pre-built binaries
  version = '1.*',
  -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
  -- build = 'cargo build --release',
  -- If you use nix, you can build from source using latest nightly rust with:
  -- build = 'nix run .#build-plugin',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
    -- 'super-tab' for mappings similar to vscode (tab to accept)
    -- 'enter' for enter to accept
    -- 'none' for no mappings
    --
    -- All presets have the following mappings:
    -- C-space: Open menu or open docs if already open
    -- C-n/C-p or Up/Down: Select next/previous item
    -- C-e: Hide menu
    -- C-k: Toggle signature help (if signature.enabled = true)
    --
    -- See :h blink-cmp-config-keymap for defining your own keymap
    keymap = { preset = 'default',
            ['<Tab>'] = { 'accept', 'fallback' },
    },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono'
    },

    -- (Default) Only show the documentation popup when manually triggered
    completion = {
            documentation = {
                auto_show = true,
                auto_show_delay_ms=10
            },
            menu = {
                draw = {
                    -- We don't need label_description now because label and label_description are already
                    -- combined together in label by colorful-menu.nvim.
                    columns = { { "kind_icon", "source", gap = 1 }, { "label", gap = 1 } },
                    components = {
                        kind_icon = {
                            text = function(ctx)
                            local icon = ctx.kind_icon
                            if vim.tbl_contains({ "Path" }, ctx.source_name) then
                                local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
                                if dev_icon then
                                    icon = dev_icon
                                end
                            else
                                icon = require("lspkind").symbolic(ctx.kind, {
                                    mode = "symbol",
                                })
                            end

                            return icon .. ctx.icon_gap
                          end,

                          -- Optionally, use the highlight groups from nvim-web-devicons
                          -- You can also add the same function for `kind.highlight` if you want to
                          -- keep the highlight groups in sync with the icons.
                          highlight = function(ctx)
                            local hl = ctx.kind_hl
                            if vim.tbl_contains({ "Path" }, ctx.source_name) then
                              local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
                              if dev_icon then
                                hl = dev_hl
                              end
                            end
                            return hl
                          end,
                        },
						source = {
                            text = function(ctx)
								return ctx.item.source_name .. ctx.icon_gap
							  end,

							  -- Optionally, use the highlight groups from nvim-web-devicons
							  -- You can also add the same function for `kind.highlight` if you want to
							  -- keep the highlight groups in sync with the icons.
							  highlight = function(ctx)
								local hl = ctx.kind_hl
								return hl
							  end,
						},
                        label = {
                            width = { fill = true, max = 60 },
                            text = function(ctx)
                                local highlights_info = require("colorful-menu").blink_highlights(ctx)
                                if highlights_info ~= nil then
                                    -- Or you want to add more item to label
                                    return highlights_info.label
                                else
                                    return ctx.label
                                end
                            end,
                            highlight = function(ctx)
                                local highlights = {}
                                local highlights_info = require("colorful-menu").blink_highlights(ctx)
                                if highlights_info ~= nil then
                                    highlights = highlights_info.highlights
                                end
                                for _, idx in ipairs(ctx.label_matched_indices) do
                                    table.insert(highlights, { idx, idx + 1, group = "BlinkCmpLabelMatch" })
                                end
                                -- Do something else
                                return highlights
                            end,
                        },
                    },
                },
            },
        },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
      default = {
        'avante',
        'git',
        'lsp',
        'path',
        'snippets',
        'buffer',
        'nerdfont',
        'ripgrep',
        },
        providers = {
            lsp = {
                name = 'LSP',
                module = 'blink.cmp.sources.lsp',
                score_offset = 15,
                opts = {
                },
            },
            nerdfont = {
                module = 'blink-nerdfont',
                name = 'Nerd Fonts',
                score_offset = -15, -- Set by preference
                opts = { insert = true },
            },
            git = {
                module = 'blink-cmp-git',
                name = 'Git',
                opts = {
                },
            },
            avante = {
                module = 'blink-cmp-avante',
                name = 'Avante',
                opts = {
                },
            },
            ripgrep = {
                module = 'blink-ripgrep',
                name = 'Ripgrep',
                opts = {
                },
            },
        },
    },


     snippets = { preset = 'luasnip' },

    -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
    -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
    -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
    --
    -- See the fuzzy documentation for more information
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  opts_extend = { "sources.default" }
}
