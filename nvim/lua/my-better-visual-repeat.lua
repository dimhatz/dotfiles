return {
  dir = '~/better-visual-repeat.nvim',
  config = function()
    local bvr = require('better-visual-repeat')
    bvr.setup({
      apply_mappings = false,
      -- logging = { enabled = true },
      editing_keys = { 'x', 'X', 'd', 'D', 'c', 'p', 'r', 'gc', '>', '<', 'U', 'u', 'm', 's' },
    })

    -- TODO: create mappings I and A in visual line to add text to beginning / end of each line

    bvr.patch_MatchitVisualForward()
    vim.keymap.set('n', 'v', bvr.better_v, { desc = 'Better v' })
    vim.keymap.set('n', '<C-v>', bvr.better_V, { desc = 'Better V' })
    vim.keymap.set('x', '.', bvr.dot_on_visual_selection, { desc = 'Better . on visual selection' })
    vim.keymap.set('x', '<C-v>', 'V', { desc = '<c-v> is new V in visual' })
    vim.keymap.set('n', 'V', '<C-v>', { desc = 'V is new <C-v>' })
    vim.keymap.set('x', 'V', '<C-v>', { desc = 'V is new <C-v> in visual' })
    vim.keymap.set('x', 'I', function()
      if vim.fn.mode(1) == 'V' then
        return '<C-v>0I'
      end
      return 'I'
    end, { expr = true, desc = 'I now also works in visual line' })
    vim.keymap.set('x', 'A', function()
      if vim.fn.mode(1) == 'V' then
        return '<C-v>$A'
      end
      return 'A'
    end, { expr = true, desc = 'A now also works in visual line' })
  end,
}
