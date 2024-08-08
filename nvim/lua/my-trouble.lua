local remap = require('my-helpers').remap
-- NOTE: when preview mode is enabled (P inside trouble's window), <c-w><c-w> will not switch windows
return {
  'folke/trouble.nvim',
  -- cmd = 'Trouble', -- lazy load on command 'Trouble'
  -- opts = {},
  lazy = false, -- otherwise remaps are not registered / helpfile not available until command is called
  config = function()
    local trouble = require('trouble')
    trouble.setup({
      focus = true, -- Focus the window when opened
      auto_refresh = true, -- TextChanged/TextChangedI will be added anyway on opening window
      -- auto_preview = false, -- automatically open preview when on an item (P toggles the preview mode inside Trouble window)
      throttle = { -- (default), make them 100x to minimize slowdowns
        refresh = 2000, -- (20) fetches new data when needed
        update = 1000, -- (10) updates the window
        render = 100, -- (10) renders the window
        follow = 1000, -- (100) follows the current item
        preview = { ms = 100, debounce = true }, -- (100) shows the preview for the current item
      },
    })
    remap('n', '<C-t>', '<cmd>Trouble diagnostics open_no_results=true<CR>', { desc = 'Open Trouble diagnostics' })
  end,
}
