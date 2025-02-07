return {
  dir = '~/better-visual-repeat.nvim',
  config = function()
    local bvr = require('better-visual-repeat')
    bvr.setup({ logging = { enabled = true }, mappings_that_edit_in_visual = { 'm', 'x', 'X', 'd', 'D', 'c', 'p', 'r', 'gc', 's', '>', '<', 'U' } })

    -- TODO: create mappings I and A in visual line to add text to beginning / end of each line

    vim.keymap.set('n', 'v', bvr.better_v, { desc = 'Better v' })
    vim.keymap.set('n', '<C-v>', bvr.better_V, { desc = 'Better V' })
    vim.keymap.set('v', '.', bvr.dot_on_visual_selection, { desc = 'Better . on visual selection' })
    vim.keymap.set('v', '<C-v>', 'V', { desc = '<c-v> is new V in visual' })
  end,
}
