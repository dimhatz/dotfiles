-- NOTE: to see all the active colors:
-- :enew
-- (to enable colorizer, set ft:)
-- :set ft=text
-- (to capture all the output into register)
-- :redir @z
-- :silent hi
-- "zp
-- :redir END

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
  base00light = '#2c2c2c', -- (29.5)
  base01 = '#3d3d3d', -- (36)
  base02 = '#606060', -- (49)
  base03 = '#868686', -- (62)
  base04 = '#aeaeae', -- (75)
  base05fg = '#d7d7d7', -- fg (88)

  blackest = '#000000',
  whitest = '#ffffff',

  -- 'dark' versions are darkened to 46%, 'less_dark' versions are darkened to 60%
  blue = '#50cdff', -- Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
  -- blue_cyan_bright = '#1fe4fe', -- 84%, 0.1422, 209
  blue_brightest_cyan = '#0ce4ff', -- oklch(84.23% 0.1446 209.98)
  blue_dark = '#006180', -- (fallb)
  blue_less_dark = '#008db7', -- 60

  violet = '#d7a5ff', -- Integers, Boolean, Constants, XML Attributes, Markup Link Url
  -- violet_brightest_magenta = '#ffa7fb', -- 84.2%, 0.146, 328
  violet_brightest_magenta = '#ffa7ff', -- same as above, maxed blue channel (rbg)
  violet_dark = '#6e3e90',
  violet_less_dark = '#9867bc',
  green = '#72d794', -- Classes, Markup Bold, Search Text Background
  green_dark = '#006a36',
  green_less_dark = '#2c9758',
  peach = '#ffa196', -- Strings, Inherited Class, Markup Code, Diff Inserted
  peach_dark = '#8d3a33',
  peach_less_dark = '#bb635a',
  -- yellow_saturated = '#d9bc4a', -- orig color at 80%
  yellow_brightest = '#eaea00',
  -- yellow_brightest_max = '#ffff00',
  -- yellow_brightest = '#ffc707',
  yellow = '#dec97c', -- 0.1 + 83.5%
  yellow_dark = '#695700', -- (fallb)
  yellow_less_dark = '#9f7b00',
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

  hi('Visual', { bg = c.base03, fg = c.blackest })
  hi('Search', { bg = c.peach_dark, fg = c.whitest })
  hi('IncSearch', { bg = c.peach_dark, fg = c.whitest })
  hi('CursorLine', { bg = c.blackest })
  hi('CursorLineNr', { bg = c.blackest, fg = c.base03 })
  hi('LineNr', { fg = c.base02 })
  hi('Comment', { fg = c.base03 })

  hi('Error', { fg = c.peach })
  hi('ErrorMsg', { link = 'Error' })
  hi('WarningMsg', { fg = c.yellow })

  -- diagnostics
  hi('DiagnosticError', { fg = c.peach_less_dark })
  hi('DiagnosticWarn', { fg = c.yellow_less_dark })
  hi('DiagnosticHint', { fg = c.green_less_dark })
  hi('DiagnosticInfo', { fg = c.blue_less_dark })
  hi('DiagnosticOk', { fg = c.green })

  hi('DiagnosticUnderlineError', { link = 'DiagnosticError' })
  hi('DiagnosticUnderlineWarn', { link = 'DiagnosticWarn' })
  hi('DiagnosticUnderlineInfo', { link = 'DiagnosticInfo' })
  hi('DiagnosticUnderlineHint', { link = 'DiagnosticHint' })
  hi('DiagnosticUnderlineOk', { link = 'DiagnosticOk' })

  hi('TSComment', { link = 'Comment' })
  hi('MatchParen', { bg = c.base02, fg = c.whitest, bold = true }) -- bold standout reverse
  hi('Wildmenu', { link = 'Search' })

  -- lsp / treesitter
  hi('LspReferenceText', { bg = c.base01 })
  hi('LspReferenceRead', { link = 'LspReferenceText' })
  hi('LspReferenceWrite', { link = 'LspReferenceText' })
  hi('TSTypeBuiltin', { link = 'TSType' }) -- do not show global types as italics
  hi('TSPunctDelimiter', { fg = c.yellow_brightest })

  -- cmp
  hi('CmpItemAbbr', { bg = c.base00bg })
  hi('CmpItemAbbrMatch', { fg = c.blue })
  hi('CmpItemAbbrMatchFuzzy', { link = 'CmpItemAbbrMatch' })
  hi('CmpItemAbbrDeprecated', { strikethrough = true })
  hi('CmpItemKindVariable', { fg = c.blue })
  hi('CmpItemKindInterface', { link = 'CmpItemKindVariable' })
  hi('CmpItemKindText', { link = 'CmpItemKindVariable' })
  hi('CmpItemKindFunction', { fg = c.yellow })
  hi('CmpItemKindMethod', { link = 'CmpItemKindFunction' })
  hi('CmpItemKindKeyword', {})
  hi('CmpItemKindProperty', { link = 'CmpItemKindKeyword' })
  hi('CmpItemKindUnit', { link = 'CmpItemKindKeyword' })

  -- rainbow delimiters
  hi('RainbowDelimiterYellow', { fg = c.yellow_brightest, bold = true })
  hi('RainbowDelimiterBlue', { fg = c.blue_brightest_cyan, bold = true })
  hi('RainbowDelimiterViolet', { fg = c.violet_brightest_magenta, bold = true })

  -- links IblWhitespace -> Whitespace -> NonText
  -- not sure where IblWhitespace is shown
  -- hi('NonText', { fg = c.base01 })
  hi('IblScope', { fg = c.base02 })
  hi('IblIndent', { fg = c.base01 })

  -- hop
  hi('HopNextKey', { fg = c.yellow_brightest })
  hi('HopNextKey1', { fg = c.yellow_brightest })
  hi('HopNextKey2', { fg = c.yellow_brightest })

  -- telescope
  hi('TelescopeMatching', { fg = c.yellow_brightest })
  hi('TelescopeSelection', { bg = c.base02, fg = c.blackest, bold = true })
  -- hi('TelescopePreviewLine', { bg = c.base02, bold = true })
  hi('TelescopePreviewLine', { reverse = true })
  -- hi('TelescopePreviewLine', { standout = true })

  -- gitsigns
  hi('DiffAdd', { fg = c.green })
  hi('DiffChange', { fg = c.blue })
  hi('DiffDelete', { fg = c.peach })
  hi('DiffText', { fg = c.yellow })

  hi('GitGutterAdd', { link = 'DiffAdd' })
  hi('GitGutterChange', { link = 'DiffChange' })
  hi('GitGutterDelete', { link = 'DiffDelete' })
  hi('GitGutterChangeDelete', { link = 'DiffChange' })

  hi('DiffAdded', { link = 'DiffAdd' })
  hi('DiffFile', { link = 'DiffText' })
  hi('DiffNewFile', { link = 'DiffAdd' })
  hi('DiffLine', { fg = c.violet })
  hi('DiffRemoved', { link = 'DiffAdd' })

  hi('GitSignsAddInline', { bg = c.green_dark, fg = c.whitest })
  hi('GitSignsDeleteInline', { bg = c.peach_dark, fg = c.whitest })
  hi('GitSignsChangeInline', { bg = c.blue_dark, fg = c.whitest })

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

  hi('BufferDefaultCurrentTarget', { fg = c.yellow_brightest, bg = c.blackest })
  hi('BufferDefaultInactiveTarget', { link = 'BufferDefaultCurrentTarget' })
  hi('BufferDefaultVisibleTarget', { link = 'BufferDefaultCurrentTarget' })
end

local M = {}
M.colors = c
M.apply_colors = apply_colors
M.apply_colors_barbar = apply_colors_barbar
return M
