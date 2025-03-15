return {
	'AlexvZyl/nordic.nvim',
	lazy = false,
	priority = 1000,
	dependencies = {
		'nvim-lualine/lualine.nvim'
	},
	config = function()
	---@diagnostic disable-next-line: missing-fields
		N = require('nordic')
		U = require('nordic.utils')
		MyColors = {
			darkblack = '#101520',
			seagreen = {
			 dim = '#467063'
			}
		}
		N.load({
		on_palette = function(palette)
			palette.gray0 = palette.black1 -- bg
			palette.gray1 = '#3B4252'
			palette.gray2 = '#434C5E'
			palette.gray3 = '#4C566A'
			palette.gray4 = '#5c6880'
		end,
		after_palette = function(palette)
			palette.border_fg = palette.gray5
			palette.fg_float_border = palette.border_fg
			palette.fg_popup_border = palette.border_fg
			palette.comment = palette.blue1 --MyColors.seagreen.dim --palette.gray5
			palette.fg_sidebar = palette.gray5
			palette.bg_visual = U.blend(palette.yellow.dim, palette.bg, .25)
		end,
		on_highlight = function(highlights, palette)
			highlights.CursorLine.bg = MyColors.darkblack
			highlights.Delimiter.fg = palette.orange.dim
			highlights.TelescopeBorder.fg = palette.border_fg
			highlights.TelescopePromptBorder.fg = palette.border_fg
			highlights.TelescopeResultsBorder.fg = palette.border_fg
			highlights.TelescopePreviewBorder.fg = palette.border_fg
			highlights.TelescopeMatching.fg = palette.orange.base
			highlights.WhichKeyBorder.fg = palette.border_fg
			--highlights.CopilotSuggestion.fg = palette.magenta.base
		end,
		})
		require('lualine').setup({
				options = {
					theme = 'nordic'
				}
			})
	end
}

--[[#region-- The Nord palette: https://www.nordtheme.com/.
-- This file has a bunch of added colors.

-- NOTE: All hex codes must be uppercase (for testing)
---@class BasePalette
local palette = {

	none = 'NONE',

	-- Blacks. Not in base Nord.
	black0 = '#191D24',
	black1 = '#1E222A',
	-- Slightly darker than bg.  Very useful for certain popups
	black2 = '#222630',

	-- Grays
	-- This color is used on their website's dark theme.
	gray0 = '#242933', --bg
	-- Polar Night.
	gray1 = '#2E3440',
	gray2 = '#3B4252',
	gray3 = '#434C5E',
	gray4 = '#4C566A',

	-- A light blue/gray.
	-- From @nightfox.nvim.
	gray5 = '#60728A',

	-- Dim white.
	-- default fg, has a blue tint.
	white0_normal = '#BBC3D4',
	-- less blue tint
	white0_reduce_blue = '#C0C8D8',

	-- Snow storm.
	white1 = '#D8DEE9',
	white2 = '#E5E9F0',
	white3 = '#ECEFF4',

	-- Frost.
	blue0 = '#5E81AC',
	blue1 = '#81A1C1',
	blue2 = '#88C0D0',

	cyan = {
		base = '#8FBCBB',
		bright = '#9FC6C5',
		dim = '#80B3B2',
	},

	-- Aurora.
	-- These colors are used a lot, so we need variations for them.
	-- Base colors are from original Nord palette.
	red = {
		base = '#BF616A',
		bright = '#C5727A',
		dim = '#B74E58',
	},
	orange = {
		base = '#D08770',
		bright = '#D79784',
		dim = '#CB775D',
	},
	yellow = {
		base = '#EBCB8B',
		bright = '#EFD49F',
		dim = '#E7C173',
	},
	green = {
		base = '#A3BE8C',
		bright = '#B1C89D',
		dim = '#97B67C',
	},
	magenta = {
		base = '#B48EAD',
		bright = '#BE9DB8',
		dim = '#A97EA1',
	},
}]]--

