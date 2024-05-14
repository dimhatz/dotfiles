return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  opts = {},
  config = function()
    require('ibl').overwrite({
      indent = {
        char = '│', -- center(│), left (▏)
      },
      scope = {
        enabled = true, -- the brighter highlighting of the current scope's guide
        show_start = false,
      },
      whitespace = {
        remove_blankline_trail = false,
      },
    })

    -- Replaces the first indentation guide for space indentation with a normal (from docs)
    -- local hooks = require('ibl.hooks')
    -- hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
  end,
}
