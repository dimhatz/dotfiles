-- -- bg #1e1e1e
--
-- oklch.com
-- 360 / 7 = 51.43 (hue is 360 degrees)
-- l: 75, c: 0.133, each color is +51.43 hue, starting at 183.66
-- #01c9b7
-- #47baf6
-- #a9a0fe
-- #e48ccc
-- #f68c7b
-- #d9a43b
-- #8dc064
--
--
-- l: 77, c: 0.1297, each color is +51.43 hue, starting at 241.12
-- #61beff -> #61b0ff (shift towards blUe)
-- #b8a4ff -> #a3a3ff (shift towards blUe)
-- #ee91c8
-- #fb9579
-- #d7af46
-- #88c876
-- #19cec7
--
-- my tests (munsell)
-- 5pb #1998fa -> oklch maxed l: #1f9bfe
-- 7.5p #f235fc, 10p #ff1fe9
-- 2.5r #ff426e, 5r #ff4557
-- 2.5yr #ff8c2e, 5yr #ffae2b
-- 5y #ffe51f, 7.5y #fce40d, 5y-maxed #ffe51f
-- 10g #12ff2a, 2.5g #54ff98
-- 5bg #5bfce7, 7.5bg #51fcf4, 10bg #42dee3
--

require('mini.base16').setup({
  palette = {
    base00 = '#112641',
    base01 = '#3a475e',
    base02 = '#606b81',
    base03 = '#8691a7',
    base04 = '#d5dc81',
    base05 = '#e2e98f',
    base06 = '#eff69c',
    base07 = '#fcffaa',
    base08 = '#ffcfa0',
    base09 = '#cc7e46',
    base0A = '#46a436',
    base0B = '#9ff895',
    base0C = '#ca6ecf',
    base0D = '#42f7ff',
    base0E = '#ffc4ff',
    base0F = '#00a5c5',
  },
  use_cterm = false,
  plugins = {
    default = true,
  },
})

-- require('mini.hues').setup({ background = '#11262d', foreground = '#c0c8cc', accent = 'yellow' })
vim.g.colors_name = 'mycolors'
