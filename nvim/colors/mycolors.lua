-- -- bg #1e1e1e
--
-- oklch.com
-- 360 / 7 = 51.43 (hue is 360 degrees)
-- l: 75%, c: 0.133, each color is +51.43 hue, starting at 183.66
-- #01c9b7
-- #47baf6
-- #a9a0fe
-- #e48ccc
-- #f68c7b
-- #d9a43b
-- #8dc064
--
--
-- bg (l = 23.5%) #1e1e1e
-- dark1 (l = 41.3%) #4b4b4b
-- dark2 (l = 59.1%) #7d7d7d
-- fg (l = 77) #b4b4b4
-- l: 77%, c: 0.1297, each color is +51.43 hue, starting at 241.12
-- #61beff -> #61b0ff (shift towards blUe)
-- #b8a4ff -> #a3a3ff (shift towards blUe)
-- #ee91c8
-- #fb9579
-- #d7af46
-- #88c876
-- #19cec7

local pal1 = {
  base00 = '#1e1e1e', -- bg (23.5%)
  base01 = '#383838', -- (34.2)
  base02 = '#555555', -- (44.9)
  base03 = '#737373', -- (55.6)
  base04 = '#939393', -- (66.3)
  base05 = '#cacaca', -- fg (83.8)
  base06 = '#d6d6d6', -- (87.7)
  base07 = '#383838', -- base01

  base08 = '#61beff', -- Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
  base09 = '#fb9579', -- Integers, Boolean, Constants, XML Attributes, Markup Link Url
  base0A = '#d7af46', -- Classes, Markup Bold, Search Text Background
  base0B = '#b8a4ff', -- Strings, Inherited Class, Markup Code, Diff Inserted
  base0C = '#19cec7', -- Support, Regular Expressions, Escape Characters, Markup Quotes
  base0D = '#88c876', -- Functions, Methods, Attribute IDs, Headings
  base0E = '#ee91c8', -- Keywords, Storage, Selector, Markup Italic, Diff Changed
  base0F = '#b8a4ff', -- Deprecated, Opening/Closing Embedded Language Tags

  blu = '#61beff',
  vio = '#b8a4ff',
  re = '#ee91c8',
  ora = '#fb9579',
  yel = '#d7af46',
  gre = '#88c876',
  cya = '#19cec7',
}

-- l: 77%, c: 0.15 six colors. color -> max chroma if possible (60 degrees equidistant)
-- #05c5ff
-- #21d2a2 -> #01d3a2
-- #bebb33 -> #bfbb01
-- #ff955a
-- #f98ac5 -> #ff84c6
-- #b1a7ff
local pal3 = {
  fg = '#b4b4b4',
  bg = '#1e1e1e',
  dark1 = '#4b4b4b',
  dark2 = '#7d7d7d',
  blu = '#05c5ff',
  vio = '#b1a7ff',
  re = '#ff84c6',
  ora = '#ff955a',
  yel = '#bfbb01',
  gre = '#78cc71',
  cya = '#01d3a2',
}

-- l: 77%, c: 0.15 six colors. color -> max chroma if possible (by the eye)
-- #05c5ff (228.4) -> towards rEd #5aa7ff -> desaturate to 0.14 #30c4fa -> 0.13 #44c4f5
-- #21d2a2 (168.2) -> #01d3a2 -> more brightness max chroma #04f2b9
-- #78cc71 (142.33) -> #0fda02 max -> less saturated #53d44b, towards blUe (153) #5bcf86
-- #bbbc35 (109.77) -> #bcbc00 -> slightly desaturated #babc47
-- #d098fc (308.86) -> #d197ff
-- #ff9181 (29.32), fallback
local pal4 = {
  base00 = '#1e1e1e', -- bg (23.5%)
  base01 = '#383838', -- (34.2)
  base02 = '#555555', -- (44.9)
  base03 = '#737373', -- (55.6)
  base04 = '#939393', -- (66.3)
  base05 = '#cacaca', -- fg (83.8)
  base06 = '#d6d6d6', -- (87.7)
  base07 = '#383838', -- base01

  base08 = '#30c4fa', -- Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
  base09 = '#ff9181', -- Integers, Boolean, Constants, XML Attributes, Markup Link Url
  base0A = '#bbbc35', -- Classes, Markup Bold, Search Text Background
  base0B = '#d098fc', -- Strings, Inherited Class, Markup Code, Diff Inserted
  base0C = '#bbbc35', -- Support, Regular Expressions, Escape Characters, Markup Quotes
  base0D = '#5bcf86', -- Functions, Methods, Attribute IDs, Headings
  base0E = '#ff9181', -- Keywords, Storage, Selector, Markup Italic, Diff Changed
  base0F = '#d098fc', -- Deprecated, Opening/Closing Embedded Language Tags
}

-- 80%, 0.135, grEen till viol fixed, the rest equidistant
-- (153) #72d794
-- (228, fallb) #50cdff
-- (309, sligh fallb) #d7a5ff
--
-- equal distance:
-- (17 fallb) #ff9fa3
-- (85) #e5b64a
-- as above + 10
-- (27) #ffa196
-- (95) #d9bc4a
--
local pal4hi = {

  base00 = '#1e1e1e', -- bg (23.5%)
  base01 = '#383838', -- (34.2)
  base02 = '#555555', -- (44.9)
  base03 = '#737373', -- (55.6)
  base04 = '#939393', -- (66.3)
  base05 = '#cacaca', -- fg (83.8)
  base06 = '#d6d6d6', -- (87.7)
  base07 = '#383838', -- base01

  base08 = '#50cdff', -- Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
  base09 = '#ffa196', -- Integers, Boolean, Constants, XML Attributes, Markup Link Url
  base0A = '#d9bc4a', -- Classes, Markup Bold, Search Text Background
  base0B = '#d7a5ff', -- Strings, Inherited Class, Markup Code, Diff Inserted
  base0C = '#d9bc4a', -- Support, Regular Expressions, Escape Characters, Markup Quotes
  base0D = '#72d794', -- Functions, Methods, Attribute IDs, Headings
  base0E = '#ffa196', -- Keywords, Storage, Selector, Markup Italic, Diff Changed
  base0F = '#d7a5ff', -- Deprecated, Opening/Closing Embedded Language Tags
}

-- l: 80%, c: 0.135, equidistant 5 colors, starting with orangE
-- (57.07) #ffa661
-- (129) #a3cf6d
-- (201) #0cd7e1
-- (273 fallback) #a8baff
-- (345) #fb99d2
local pal80 = {
  base00 = '#1e1e1e', -- bg (23.5%)
  base01 = '#383838', -- (34.2)
  base02 = '#555555', -- (44.9)
  base03 = '#737373', -- (55.6)
  base04 = '#939393', -- (66.3)
  base05 = '#cacaca', -- fg (83.8)
  base06 = '#d6d6d6', -- (87.7)
  base07 = '#383838', -- base01

  base08 = '#a8baff', -- Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
  base09 = '#ffa661', -- Integers, Boolean, Constants, XML Attributes, Markup Link Url
  base0A = '#a3cf6d', -- Classes, Markup Bold, Search Text Background
  base0B = '#fb99d2', -- Strings, Inherited Class, Markup Code, Diff Inserted
  base0C = '#a3cf6d', -- Support, Regular Expressions, Escape Characters, Markup Quotes
  base0D = '#0cd7e1', -- Functions, Methods, Attribute IDs, Headings
  base0E = '#ffa661', -- Keywords, Storage, Selector, Markup Italic, Diff Changed
  base0F = '#fb99d2', -- Deprecated, Opening/Closing Embedded Language Tags
}

-- todo: check how these look
-- l: 80% c: 0.135, starting with at 230.37
-- (231) #5cccff (fallback, auto-desaturated to 0.125)
-- (303) #ceaaff (fallback)
-- (15) #ff9ea6 (fallback)
-- (87) #e3b749
-- (159) #65d89e

-- base00 - Default Background
-- base01 - Lighter Background (Used for status bars, line number and folding marks)
-- base02 - Selection Background
-- base03 - Comments, Invisibles, Line Highlighting
-- base04 - Dark Foreground (Used for status bars)
-- base05 - Default Foreground, Caret, Delimiters, Operators
-- base06 - Light Foreground (Not often used)
-- base07 - Light Background (Not often used)
-- base08 - Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
-- base09 - Integers, Boolean, Constants, XML Attributes, Markup Link Url
-- base0A - Classes, Markup Bold, Search Text Background
-- base0B - Strings, Inherited Class, Markup Code, Diff Inserted
-- base0C - Support, Regular Expressions, Escape Characters, Markup Quotes
-- base0D - Functions, Methods, Attribute IDs, Headings
-- base0E - Keywords, Storage, Selector, Markup Italic, Diff Changed
-- base0F - Deprecated, Opening/Closing Embedded Language Tags

-- l: 77%, c: 0.1495 five colors equidistant. color -> max chroma if possible
-- 227.65 #01c5fe
-- 299.45, #c19fff (fallback)
-- 11.45 #ff8d9d (fallback)
-- 83.45 #e1aa24
-- 155.45 #55d08a
local pal5 = {
  base00 = '#1e1e1e', -- bg (23.5%)
  base01 = '#383838', -- (34.2)
  base02 = '#555555', -- (44.9)
  base03 = '#737373', -- (55.6)
  base04 = '#939393', -- (66.3)
  -- base05 = '#b4b4b4', -- fg (77)
  base05 = '#cacaca', -- fg (83.8)
  base06 = '#d6d6d6', -- (87.7)
  base07 = '#383838', -- base01

  base08 = '#01c5fe', -- Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
  base09 = '#ff8d9d', -- Integers, Boolean, Constants, XML Attributes, Markup Link Url
  base0A = '#e1aa24', -- Classes, Markup Bold, Search Text Background
  base0B = '#c19fff', -- Strings, Inherited Class, Markup Code, Diff Inserted
  base0C = '#e1aa24', -- Support, Regular Expressions, Escape Characters, Markup Quotes
  base0D = '#55d08a', -- Functions, Methods, Attribute IDs, Headings
  base0E = '#ff8d9d', -- Keywords, Storage, Selector, Markup Italic, Diff Changed
  base0F = '#c19fff', -- Deprecated, Opening/Closing Embedded Language Tags
  cya = '#000000',
  blu = '#01c5fe',
  vio = '#c19fff',
  re = '#ff8d9d',
  ora = '#e1aa24',
  yel = '#000000',
  gre = '#55d08a',
}

--
-- my tests (munsell)
-- 5pb #1998fa -> oklch maxed l: #1e9bff
-- 7.5p #f235fc, 10p #ff1fe9
-- 2.5r #ff426e, 5r #ff4557
-- 2.5yr #ff8c2e, 5yr #ffae2b
-- 5y #ffe51f, 7.5y #fce40d, 5y-maxed #ffe51f
-- 10g #12ff2a, 2.5g #54ff98
-- 5bg #5bfce7, 7.5bg #51fcf4, 10bg #42dee3
local pal2 = {
  fg = '#b4b4b4',
  bg = '#1e1e1e',
  dark1 = '#4b4b4b',
  dark2 = '#7d7d7d',
  blue = '#1e9bff',
  violet = '#f235fc',
  red = '#ff426e',
  orange = '#ff8c2e',
  yellow = '#ffe51f',
  green = '#12ff2a',
  cyan = '#5bfce7',
}

require('mini.base16').setup({
  palette = pal4hi,
  -- palette = {
  --   base00 = '#1e1e1e', -- bg (23.5%)
  --   base01 = '#383838', -- (34.2)
  --   base02 = '#555555', -- (44.9)
  --   base03 = '#737373', -- (55.6)
  --   base04 = '#939393', -- (66.3)
  --   -- base05 = '#b4b4b4', -- fg (77)
  --   base05 = '#cacaca', -- fg (83.8)
  --   base06 = '#d6d6d6', -- (87.7)
  --   base07 = '#383838', -- base01
  --   base08 = pal4.blu,
  --   base09 = pal4.ora,
  --   base0A = pal4.cya,
  --   base0B = pal4.gre,
  --   base0C = pal4.cya,
  --   base0D = pal4.vio,
  --   base0E = pal4.ora,
  --   base0F = pal4.blu,
  -- },
  --   base00 = '#112641',
  --   base01 = '#3a475e',
  --   base02 = '#606b81',
  --   base03 = '#8691a7',
  --   base04 = '#d5dc81',
  --   base05 = '#e2e98f',
  --   base06 = '#eff69c',
  --   base07 = '#fcffaa',
  --   base08 = '#ffcfa0',
  --   base09 = '#cc7e46',
  --   base0A = '#46a436',
  --   base0B = '#9ff895',
  --   base0C = '#ca6ecf',
  --   base0D = '#42f7ff',
  --   base0E = '#ffc4ff',
  --   base0F = '#00a5c5',
  use_cterm = false,
  plugins = {
    default = true,
  },
})

-- require('mini.hues').setup({ background = '#11262d', foreground = '#c0c8cc', accent = 'yellow' })
vim.g.colors_name = 'mycolors'
