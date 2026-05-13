-- `south` — a warm-palette twin of `nordic`. Same engine, same dark background;
-- blues/greens/purples swapped for reds/oranges/golds. Use `:colorscheme south`.
--
-- Mapping (cool -> hot):
--   blue0/1/2 (frost) -> deep red, coral, peach
--   cyan      (frost) -> warm coral
--   green     (aurora)-> burnt orange / ember
--   magenta   (aurora)-> gold / amber
-- The existing red/orange/yellow channels are already warm and are kept as-is.

local ok, nordic = pcall(require, 'nordic')
if not ok then
    vim.notify('south: nordic.nvim not installed', vim.log.levels.ERROR)
    return
end
local U = require('nordic.utils')

local SouthColors = {
    -- A near-black with a faint warm undertone for cursorline.
    darkblack = '#100C0A',
    -- Slightly warmed dark for floats/menus.
    old_gray0 = '#241C18',
    -- Cool accents used as emphasis against the warm primary. Nord pops
    -- warm against cool; south pops cool against warm.
    ice       = '#88BBDC', -- light cool blue for search / cursor pop
    frost     = '#6FB3A0', -- cool teal-green for matches
}

nordic.load({
    on_palette = function(palette)
        -- Background grays kept neutral — the *dark tone* the user asked us to keep.
        -- Only gray5 gets a slight warm shift since it's used for comments/borders
        -- and would otherwise read as cool against an all-warm chromatic palette.
        palette.gray0 = palette.black1 -- bg
        palette.gray1 = '#2E2A26'
        palette.gray2 = '#3D3631'
        palette.gray3 = '#4F4640'
        palette.gray4 = '#615650'
        palette.gray5 = '#8C7866'

        -- Frost (cool blues) -> warm red gradient. All three slots stay warm
        -- because the user wants the warm-primary feel; cool tones for normal
        -- syntax come via the explicit @-group overrides further below.
        palette.blue0 = '#B85042' -- deep crimson
        palette.blue1 = '#D17666' -- mid coral-red
        palette.blue2 = '#E5A38B' -- light peach

        -- Cyan kept cool — the primary "emphasis" slot. Types, references and
        -- variables resolve through this group; keeping it cool gives every code
        -- buffer the warm-vs-cool contrast that makes nord (and now south) feel alive.
        palette.cyan = {
            base   = '#7FB5C4',
            bright = '#9FC9D6',
            dim    = '#608898',
        }

        -- Aurora green -> burnt orange / ember.
        palette.green = {
            base   = '#CE8044',
            bright = '#DC9659',
            dim    = '#B36F35',
        }

        -- Aurora magenta -> gold / amber.
        palette.magenta = {
            base   = '#D4A24C',
            bright = '#E2B96A',
            dim    = '#B88A38',
        }
        -- red / orange / yellow are already warm; left untouched.
    end,

    after_palette = function(palette)
        palette.border_fg       = palette.gray5
        palette.fg_float_border = palette.border_fg
        palette.fg_popup_border = palette.border_fg
        palette.comment         = palette.gray5 -- muted warm gray for comments
        palette.fg_sidebar      = palette.gray5
        -- Visual selection blends cool against the warm bg for emphasis.
        palette.bg_visual       = U.blend(palette.cyan.base, palette.bg, .25)
    end,

    on_highlight = function(highlights, palette)
        highlights.CursorLine.bg   = SouthColors.darkblack
        highlights.CursorLineNr.fg = SouthColors.ice -- cool pop for current line number
        highlights.Delimiter.fg    = palette.orange.dim

        -- Search & matches: cool pop against warm code.
        U.merge_inplace(highlights, {
            Search    = { fg = palette.black0, bg = palette.cyan.bright },
            IncSearch = { fg = palette.black0, bg = SouthColors.ice },
            CurSearch = { fg = palette.black0, bg = SouthColors.ice },
        })

        U.merge_inplace(highlights, { FoldColumn      = { bg = palette.gray0 } })
        U.merge_inplace(highlights, { FoldLine        = { bg = palette.gray0 } })
        U.merge_inplace(highlights, { FoldLineCurrent = { fg = palette.yellow.base, bg = palette.gray0 } })

        -- LSP / treesitter
        highlights['@parameter'].fg = palette.white0_reduce_blue

        -- Cool accents on high-frequency normal-syntax tokens. Keeps the warm
        -- primary feel intact but gives every OOP-style line a cool pop where
        -- you read it most (obj.field, self.attr, struct->member).
        U.merge_inplace(highlights, {
            ['@variable.member']  = { fg = palette.cyan.base },
            ['@property']         = { fg = palette.cyan.base },
            ['@field']            = { fg = palette.cyan.base },
            ['@variable.builtin'] = { fg = SouthColors.ice, italic = true }, -- self / this / None / nil
            ['@lsp.type.property'] = { fg = palette.cyan.base },
            ['@lsp.type.member']   = { fg = palette.cyan.base },
        })

        -- WhichKey
        ---@diagnostic disable-next-line: undefined-field
        highlights.WhichKeyBorder.fg = palette.border_fg

        highlights.NormalFloat = { bg = SouthColors.old_gray0 }

        -- blink.cmp — re-keyed to warm sources. The base color groups still resolve
        -- correctly because we replaced blue/cyan/green/magenta at the palette level.
        local BCMP = {
            BlinkCmpMenu          = { bg = SouthColors.old_gray0 },
            -- Match highlight pops cool against warm primary palette.
            BlinkCmpLabelMatch    = { fg = SouthColors.ice, bold = true },
            BlinkCmpKindField     = { link = '@field' },
            BlinkCmpKindProperty  = { link = '@property' },
            BlinkCmpKindEvent     = { link = 'Type' },
            BlinkCmpKindText      = { fg = palette.gray4 },
            BlinkCmpKindEnum      = { link = 'Type' },
            BlinkCmpKindKeyword   = { link = 'Keyword' },
            BlinkCmpKindConstant  = { link = 'Constant' },
            BlinkCmpKindConstructor = { link = 'Function' },
            BlinkCmpKindReference = { fg = palette.cyan.base },
            BlinkCmpKindFunction  = { link = 'Function' },
            BlinkCmpKindStruct    = { link = 'Type' },
            BlinkCmpKindClass     = { link = 'Type' },
            BlinkCmpKindModule    = { fg = palette.yellow.dim },
            BlinkCmpKindOperator  = { link = 'Operator' },
            BlinkCmpKindVariable  = { fg = palette.cyan.base },
            BlinkCmpKindFile      = { fg = palette.blue1 },
            BlinkCmpKindUnit      = { link = 'Constant' },
            BlinkCmpKindSnippet   = { fg = palette.blue1 },
            BlinkCmpKindFolder    = { fg = palette.yellow.dark },
            BlinkCmpKindMethod    = { link = 'Function' },
            BlinkCmpKindValue     = { link = 'Constant' },
            BlinkCmpKindEnumMember = { link = 'Type' },
            BlinkCmpKindInterface = { link = 'Type' },
            BlinkCmpKindColor     = { link = 'Constant' },
            BlinkCmpKindTypeParameter = { link = 'Type' },
            BlinkCmpKindTabNine   = { fg = palette.red.base },
            BlinkCmpKindCopilot   = { fg = palette.blue2 },
            BlinkCmpKindConventional_Commits = { fg = palette.yellow.base },
            -- Source badges (kept colorful so each source stays distinguishable
            -- against the warm palette).
            BlinkCmpSourceGit                 = { fg = palette.black0, bg = palette.green.base },
            BlinkCmpSourceLSP                 = { fg = palette.black0, bg = palette.green.dim },
            BlinkCmpSourcePath                = { fg = palette.black0, bg = palette.blue2 },
            BlinkCmpSourceSnippets            = { fg = palette.black0, bg = palette.yellow.dim },
            BlinkCmpSourceBuffer              = { fg = palette.black0, bg = palette.orange.dim },
            BlinkCmpSourceNerdfont            = { fg = palette.black0, bg = palette.orange.bright },
            BlinkCmpSourceRipgrep             = { fg = palette.white0, bg = palette.red.dim },
            BlinkCmpSourceCopilot             = { fg = palette.white0, bg = palette.blue0 },
            BlinkCmpSourceConventional_Commits = { fg = palette.black0, bg = palette.yellow.base },
            BlinkCmpDoc                       = { bg = SouthColors.old_gray0 },
            BlinkCmpDocSeparator              = { bg = SouthColors.old_gray0 },
            BlinkCmpSignatureHelp             = { bg = SouthColors.old_gray0 },
        }
        U.merge_inplace(highlights, BCMP)

        -- nvim-notify icons — warm-side palette for severity colors.
        local NOTIFY = {
            NotifyERRORBorder = { fg = palette.black0, bg = palette.black0 },
            NotifyWARNBorder  = { fg = palette.black0, bg = palette.black0 },
            NotifyINFOBorder  = { fg = palette.black0, bg = palette.black0 },
            NotifyDEBUGBorder = { fg = palette.black0, bg = palette.black0 },
            NotifyTraceBorder = { fg = palette.black0, bg = palette.black0 },
            NotifyERRORIcon   = { fg = palette.white0, bg = '#C73838' },
            NotifyWARNIcon    = { fg = palette.black0, bg = '#E08F3A' },
            NotifyINFOIcon    = { fg = palette.black0, bg = '#E8C474' },
            NotifyDEBUGIcon   = { fg = palette.black0, bg = '#8B8B8B' },
            NotifyTraceIcon   = { fg = palette.black0, bg = '#D08770' },
            NotifyERRORTitle  = { fg = palette.white0, bg = '#C73838' },
            NotifyWARNTitle   = { fg = palette.black0, bg = '#E08F3A' },
            NotifyINFOTitle   = { fg = palette.black0, bg = '#E8C474' },
            NotifyDEBUGTitle  = { fg = palette.black0, bg = '#8B8B8B' },
            NotifyTraceTitle  = { fg = palette.black0, bg = '#D08770' },
            NotifyERRORBody   = { bg = palette.gray1 },
            NotifyWARNBody    = { bg = palette.gray1 },
            NotifyINFOBody    = { bg = palette.gray1 },
            NotifyDEBUGBody   = { bg = palette.gray1 },
            NotifyTraceBody   = { bg = palette.gray1 },
        }
        U.merge_inplace(highlights, NOTIFY)

        -- Telescope
        ---@diagnostic disable-next-line: undefined-field
        highlights.TelescopeBorder.fg        = palette.border_fg
        ---@diagnostic disable-next-line: undefined-field
        highlights.TelescopePromptBorder.fg  = palette.border_fg
        ---@diagnostic disable-next-line: undefined-field
        highlights.TelescopeResultsBorder.fg = palette.border_fg
        ---@diagnostic disable-next-line: undefined-field
        highlights.TelescopePreviewBorder.fg = palette.border_fg
        ---@diagnostic disable-next-line: undefined-field
        highlights.TelescopeMatching.fg      = SouthColors.ice
    end,
})

-- nordic.load() sets colors_name to 'nordic'. Override so :colorscheme/runtime
-- queries report the actual scheme in use.
vim.g.colors_name = 'south'
