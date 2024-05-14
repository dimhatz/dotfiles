-- folke/which-key.nvim, shows pending keybinds.
return {
  'folke/which-key.nvim',
  event = 'VimEnter', -- Sets the loading event to 'VimEnter'
  config = function() -- This is the function that runs, AFTER loading
    require('which-key').setup({
      plugins = {
        marks = true, -- shows a list of your marks on ' and `
        registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        -- the presets plugin, adds help for a bunch of default keybindings in Neovim
        -- No actual key bindings are created
        spelling = {
          enabled = false, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
        },
        presets = {
          operators = false, -- adds help for operators like d, y, ...
          motions = false, -- adds help for motions
          text_objects = false, -- help for text objects triggered after entering an operator
          windows = true, -- default bindings on <c-w>
          nav = true, -- misc bindings to work with windows
          z = false, -- we use z as "_d (bindings for folds, spelling and others prefixed with z)
          g = true, -- bindings for prefixed with g
        },
      },
      window = {
        border = 'single',
      },
      triggers_blacklist = {
        n = { 'd' },
      },
    })

    -- Document existing key chains
    require('which-key').register({
      ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
      ['<leader>g'] = { name = '[G]itsigns', _ = 'which_key_ignore' },
    })
  end,
}
