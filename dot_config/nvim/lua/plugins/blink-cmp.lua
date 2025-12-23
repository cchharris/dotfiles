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
        'L3MON4D3/LuaSnip',
        version = 'v2.*',
        'onsails/lspkind.nvim',
        "xzbdmw/colorful-menu.nvim",
        'giuxtaposition/blink-cmp-copilot',
        'disrupted/blink-cmp-conventional-commits',
    },
    cond = not vim.g.vscode,

    -- use a release tag to download pre-built binaries
    version = '1.*',
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    -- build = 'nix run .#build-plugin',

    config = function()
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        require("blink.cmp").setup({
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
            keymap = {
                preset = 'default',
                ['<Tab>'] = {
                    "snippet_forward",
                    function() -- sidekick next edit suggestion
                        return require("sidekick").nes_jump_or_apply()
                    end,
                    function() -- if you are using Neovim's native inline completions
                        return vim.lsp.inline_completion.get()
                    end,
                    "fallback",
                },
            },

            appearance = {
                -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = 'mono'
            },

            -- (Default) Only show the documentation popup when manually triggered
            completion = {
                ghost_text = {
                    enabled = true,
                    show_with_menu = true,
                },
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 10,
                    window = {
                        border = 'none',
                    },
                },
                menu = {
                    border = 'none',
                    draw = {
                        -- We don't need label_description now because label and label_description are already
                        -- combined together in label by colorful-menu.nvim.
                        columns = { { "source", gap = 1 }, { "kind_icon", gap = 1 }, { "label", gap = 1 }, },
                        components = {
                            kind_icon = {
                                text = function(ctx)
                                    local icon = ctx.kind_icon
                                    if vim.tbl_contains({ "Path" }, ctx.source_name) then
                                        local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
                                        if dev_icon then
                                            icon = dev_icon
                                        end
                                    elseif icon == nil or icon == "" then
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
                                    elseif ctx.source_name == "Copilot" then
                                        hl = "BlinkCmpKindCopilot"              -- Custom highlight group for Copilot
                                    elseif ctx.source_name == "conventional_commits" then
                                        hl = "BlinkCmpKindConventional_Commits" -- Custom highlight group for Copilot
                                    end
                                    return hl
                                end,
                            },
                            source = {
                                text = function(ctx)
                                    if ctx.item.source_name == 'LSP' then
                                        local info = vim.lsp.get_client_by_id(ctx.item.client_id)
                                        local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.item.client_name)
                                        if dev_icon then
                                            return dev_icon .. ' ' .. ctx.item.client_name .. ctx.icon_gap
                                        end
                                        return ctx.item.client_name .. ctx.icon_gap
                                    end
                                    return ctx.item.source_name .. ctx.icon_gap
                                end,

                                -- Optionally, use the highlight groups from nvim-web-devicons
                                -- You can also add the same function for `kind.highlight` if you want to
                                -- keep the highlight groups in sync with the icons.
                                highlight = function(ctx)
                                    local hl = ctx.kind_hl
                                    hl = "BlinkCmpSource" .. ctx.item.source_id
                                    --[[
                                    if ctx.item.source_name == 'LSP' then
                                        local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.item.client_name)
                                        if dev_icon then
                                            hl = dev_hl
                                        end
                                    elseif ctx.item.source_name == "Copilot" then
                                        hl = "BlinkCmpKindCopilot" -- Custom highlight group for Copilot
                                    end
                                    --]]
                                    return hl
                                end,
                            },
                            label = {
                                width = { fill = true, max = 60 },
                                text = function(ctx)
                                    local highlights_info = require("colorful-menu").blink_highlights(ctx)
                                    if ctx.source_id == 'copilot' then
                                        return '---->'
                                    end
                                    if highlights_info ~= nil then
                                        -- Or you want to add more item to label
                                        local ret = highlights_info.label
                                        if ctx.label_detail then
                                            ret = ret .. ' ' .. ctx.label_detail
                                        end
                                        return ret
                                    else
                                        return ctx.label .. ' ' .. ctx.label_detail
                                    end
                                end,
                                highlight = function(ctx)
                                    local highlights = {}
                                    local highlights_info = require("colorful-menu").blink_highlights(ctx)
                                    if highlights_info ~= nil then
                                        highlights = highlights_info.highlights
                                    end
                                    if ctx.source_id ~= 'copilot' then
                                        if ctx.label_matched_indices ~= nil then
                                            for _, idx in ipairs(ctx.label_matched_indices) do
                                                table.insert(highlights, { idx, idx + 1, group = "BlinkCmpLabelMatch" })
                                            end
                                        end
                                    end
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
                    'copilot',
                    'conventional_commits',
                    'lazydev',
                },
                providers = {
                    lsp = {
                        name = 'LSP',
                        module = 'blink.cmp.sources.lsp',
                        score_offset = 15,
                        fallbacks = { 'buffer' },
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
                        enabled = function()
                            return vim.tbl_contains({ 'octo', 'gitcommit', 'markdown' }, vim.bo.filetype)
                        end,
                        module = 'blink-cmp-git',
                        name = 'Git',
                        max_items = 5,
                        score_offset = 0, -- We'll likely be searching by message/hash
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
                        async = true, -- Enable async for ripgrep to avoid blocking
                        opts = {
                        },
                    },
                    copilot = {
                        module = 'blink-cmp-copilot',
                        name = 'Copilot',
                        score_offset = 100,
                        async = true,
                        transform_items = function(_, items)
                            for _, item in ipairs(items) do
                                item.kind_icon = ''
                            end
                            return items
                        end,
                        opts = {
                        },
                    },
                    conventional_commits = {
                        module = 'blink-cmp-conventional-commits',
                        name = 'ConCom',
                        enabled = function()
                            return vim.bo.filetype == 'gitcommit'
                        end,
                        transform_items = function(_, items)
                            for _, item in ipairs(items) do
                                item.kind_icon = '󰊢'
                            end
                            return items
                        end,
                        opts = {},
                    },
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        -- make lazydev completions top priority (see `:h blink.cmp`)
                        score_offset = 100,
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
        })
        vim.api.nvim_create_autocmd('User', {
            pattern = 'BlinkCmpMenuOpen',
            callback = function()
                require("copilot.suggestion").dismiss()
                vim.b.copilot_suggestion_hidden = true
            end,
        })
        vim.api.nvim_create_autocmd('User', {
            pattern = 'BlinkCmpMenuClose',
            callback = function()
                vim.b.copilot_suggestion_hidden = false
            end,
        })
    end,
    opts_extend = { "sources.default" }
}
