-- creates global highlight group, with namespace ns=0 (global)
local function hi(name, opts)
  vim.api.nvim_set_hl(0, name, opts)
end

-- 80%, 0.135, green, blue, viol are fixed, to provide good contrast
-- (153) #72d794
-- (228, fallb) #50cdff
-- (309, sligh fallb) #d7a5ff
--
-- equal distance for the next 2:
-- (17 fallb) #ff9fa3
-- (85) #e5b64a
-- as above + 10
-- (27) #ffa196
-- (95) #d9bc4a
-- --> #dec97c desaturate to 0.1 + 83.5%

-- for adjustments: https://oklch.com/
local c = {
  base00bg = '#1d1d1d', -- bg (23)
  base01 = '#3d3d3d', -- (36)
  base02 = '#606060', -- (49)
  base03 = '#868686', -- (62)
  base04 = '#aeaeae', -- (75)
  base05fg = '#d7d7d7', -- fg (88)

  blackest = '#000000',
  whitest = '#ffffff',
  -- dark versions are desaturated to 46%
  blue = '#50cdff', -- Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
  blue_dark = '#006180', -- (fallb)
  violet = '#d7a5ff', -- Integers, Boolean, Constants, XML Attributes, Markup Link Url
  violet_dark = '#6e3e90',
  green = '#72d794', -- Classes, Markup Bold, Search Text Background
  green_dark = '#006a36',
  peach = '#ffa196', -- Strings, Inherited Class, Markup Code, Diff Inserted
  peach_dark = '#8d3a33',
  peach_faded = '#dc8277', -- 70%
  -- yellow = '#d9bc4a', -- orig
  yellow = '#dec97c', -- 0.1 + 83.5%
  yellow_dark = '#695700', -- (fallb)
}

local function apply_colors()
  require('base16-colorscheme').setup({
    base00 = c.base00bg, -- bg (23) -- Default Background
    base01 = c.base01, -- (36) -- Lighter Background (Used for status bars, line number and folding marks)
    base02 = c.base02, -- (49) -- Selection Background
    base03 = c.base03, -- (62) -- Comments, Invisibles, Line Highlighting
    base04 = c.base04, -- (75) -- Dark Foreground (Used for status bars)
    base05 = c.base05fg, -- fg (88) -- Default Foreground, Caret, Delimiters, Operators
    base06 = c.whitest, -- (100) -- Light Foreground (Not often used)
    base07 = c.base04, -- base04 -- Light Background (Not often used)

    base08 = c.blue, -- Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
    base09 = c.violet, -- Integers, Boolean, Constants, XML Attributes, Markup Link Url
    base0A = c.green, -- Classes, Markup Bold, Search Text Background
    base0B = c.peach, -- Strings, Inherited Class, Markup Code, Diff Inserted
    base0C = c.green, -- Support, Regular Expressions, Escape Characters, Markup Quotes
    base0D = c.yellow, --  Functions, Methods, Attribute IDs, Headings
    base0E = c.violet, -- Keywords, Storage, Selector, Markup Italic, Diff Changed
    base0F = c.violet, -- Deprecated, Opening/Closing Embedded Language Tags
  })

  hi('Search', { bg = c.peach_dark, fg = c.whitest })
  hi('IncSearch', { bg = c.peach_dark, fg = c.whitest })
  hi('CursorLine', { bg = c.blackest })
  hi('CursorLineNr', { bg = c.blackest, fg = c.base03 })
  hi('LineNr', { fg = c.base02 })

  -- barbar
  hi('BufferDefaultCurrent', { bg = c.base01, fg = c.whitest })
  vim.api.nvim_set_hl(0, 'BufferDefaultCurrent', { bg = '#000000', fg = '#ffffff' })

  vim.g.colors_name = 'mycolors'
end

local function apply_colors_barbar()
  -- using same bg/fg for Sign, since barbar does not allow combination
  -- of Mod+Sign / Mod+Sign
  hi('BufferDefaultCurrent', { bg = c.blue_dark, fg = c.whitest })

  hi('BufferDefaultCurrentSign', { bg = c.base01, fg = c.base01 }) -- make it blend in with the surroundings
  hi('BufferDefaultCurrentMod', { bg = c.peach_dark, fg = c.whitest })

  hi('BufferDefaultInactive', { bg = c.base01, fg = c.base05fg })
  hi('BufferDefaultInactiveSign', { bg = c.base01, fg = c.base01 })
  hi('BufferDefaultInactiveMod', { bg = c.base01, fg = c.peach })

  hi('BufferDefaultVisible', { bg = c.base02, fg = c.whitest })
  hi('BufferDefaultVisibleSign', { bg = c.base01, fg = c.base01 })
  hi('BufferDefaultVisibleMod', { bg = c.base02, fg = c.yellow })

  hi('BufferTabpageFill', { bg = c.base01 })
end

local M = {}
M.colors = c
M.apply_colors = apply_colors
M.apply_colors_barbar = apply_colors_barbar
return M
