return {
  'HiPhish/rainbow-delimiters.nvim',
  -- TODO: sometimes rainbow is not highlighting, even with treesitter dep
  -- but on :InspectTree rainbow starts highlighting
  -- same with the following command
  -- testing lazy = false now --> it seems that this forces initial highlighting when opening
  -- file, but for the new code inserted, the parens are still not highlighted,
  -- thus, using the above workaround on <Esc> to update treesitter, see my-helpers -> update_treesitter_tree()
  lazy = false,
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
  },
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
