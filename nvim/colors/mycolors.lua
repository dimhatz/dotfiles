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
  fg = '#b4b4b4',
  bg = '#1e1e1e',
  dark1 = '#4b4b4b',
  dark2 = '#7d7d7d',
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
-- #05c5ff (228.4) -> towards rEd #5aa7ff
-- #21d2a2 (168.2) -> #01d3a2 -> more brightness max chroma #04f2b9
-- #78cc71 (142.33) -> #0fda02 max -> less saturated #53d44b
-- #bbbc35 (109.77) -> #bcbc00 -> slightly desaturated #babc47
-- #d098fc (308.86) -> #d197ff
-- #ff9181 (29.32), fallback
local pal4 = {
  fg = '#b4b4b4',
  bg = '#1e1e1e',
  dark1 = '#4b4b4b',
  dark2 = '#7d7d7d',
  cya = '#01d3a2',
  blu = '#05c5ff',
  vio = '#d098fc',
  re = '#000000',
  ora = '#ff9181',
  yel = '#babc47',
  gre = '#78cc71',
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
--
-- munsell2 (no rEd)
--
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
  palette = { -- minischeme
    base00 = pal4.bg,
    base01 = pal4.dark1,
    base02 = pal4.dark2,
    base03 = pal4.fg,
    base04 = pal4.fg,
    base05 = pal4.yel,
    base06 = pal4.yel,
    base07 = pal4.yel,
    base08 = pal4.blu,
    base09 = pal4.ora,
    base0A = pal4.cya,
    base0B = pal4.gre,
    base0C = pal4.cya,
    base0D = pal4.vio,
    base0E = pal4.ora,
    base0F = pal4.blu,
  },
  -- palette = { -- minischeme
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
  -- },
  use_cterm = false,
  plugins = {
    default = true,
  },
})

-- require('mini.hues').setup({ background = '#11262d', foreground = '#c0c8cc', accent = 'yellow' })
vim.g.colors_name = 'mycolors'
