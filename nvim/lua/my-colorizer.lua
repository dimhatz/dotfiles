return {
  'NvChad/nvim-colorizer.lua',
  event = 'VeryLazy',
  opts = {
    filetypes = { 'lua', 'text' },
    user_default_options = {
      mode = 'virtualtext',
      virtualtext = '',
      names = false,
      RGB = true,
      RRGGBB = true,
      RRGGBBAA = true,
      always_update = false,
    },
  },
}
