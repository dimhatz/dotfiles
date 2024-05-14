return {
  'RRethy/base16-nvim',
  lazy = false,
  priority = math.huge,
  -- config instead of init, to execute after the plugin was loaded
  config = function()
    require('base16-colorscheme').with_config({
      telescope = false,
      indentblankline = false,
      cmp = false,
      notify = false,
      ts_rainbow = false,
      illuminate = false,
      dapui = false,
    })

    -- no need to setup, since we are calling this anyway from our colors
    -- require('base16-colorscheme').setup()

    -- initializing here, to ensure base16 was added to path by Lazy, since we need it in mycolors.lua
    require('mycolors').apply_colors()
  end,
}
