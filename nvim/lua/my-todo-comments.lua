-- folke/todo-comments.nvim, Highlight todo, notes, etc in comments
return {
  'folke/todo-comments.nvim',
  -- TODO: test test
  -- FIXME: test
  -- HACK: test
  -- WARN: test
  -- NOTE: test
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
    signs = false,
    highlight = {
      keyword = 'wide_fg',
      multiline = false, -- only act on a single line
      after = '', -- do not add colors to the following text
      before = '',
    },
    gui_style = {
      fg = 'bold',
    },
  },
}
