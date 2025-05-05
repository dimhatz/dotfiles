return {
  dir = '~/better-visual-repeat.nvim',
  config = function()
    local bvr = require('better-visual-repeat')
    bvr.setup({
      apply_mappings = false,
      -- logging = { enabled = true, on_key = true },
      editing_keys = { 'x', 'X', 'd', 'D', 'c', 'p', 'r', 'gc', '>', '<', 'U', 'u', 'm', 's' },
    })

    bvr.patch_MatchitVisualForward()
    vim.keymap.set('n', 'v', bvr.better_v, { desc = 'Better v' })
    vim.keymap.set('n', '<C-v>', bvr.better_V, { desc = 'Better V' })
    vim.keymap.set('x', '.', bvr.dot_on_visual_selection, { desc = 'Better . on visual selection' })
    vim.keymap.set('x', '<C-v>', 'V', { desc = '<c-v> is new V in visual' })
    vim.keymap.set('n', 'V', '<C-v>', { desc = 'V is new <C-v>' })
    vim.keymap.set('x', 'V', '<C-v>', { desc = 'V is new <C-v> in visual' })
    vim.keymap.set('x', '<', function()
      if vim.fn.mode(1) == 'V' then
        return '<C-v>0I'
      end
      return 'I'
    end, { expr = true, desc = 'Insert in the beginning of visual line (My)' })
    vim.keymap.set('x', '>', function()
      if vim.fn.mode(1) == 'V' then
        return '<C-v>$A'
      end
      return 'A'
    end, { expr = true, desc = 'Insert in the end of visual line (My)' })
  end,
}
