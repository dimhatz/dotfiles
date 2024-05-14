return {
  'HiPhish/rainbow-delimiters.nvim',
  init = function()
    require('rainbow-delimiters.setup').setup({
      -- strategy = {},
      -- query = {},
      highlight = {
        'RainbowDelimiterBlue',
        'RainbowDelimiterViolet',
        'RainbowDelimiterYellow',
      },
    })
  end,
}
