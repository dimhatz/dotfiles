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
    vim.keymap.set('n', 'r', bvr.better_v, { desc = 'Better v (remark visually)' })
    vim.keymap.set('n', '<C-r>', bvr.better_V, { desc = 'Better V (remark visually)' })
    vim.keymap.set('x', '_', bvr.dot_on_visual_selection, { desc = 'Better . on visual selection' })
    vim.keymap.set('x', '<C-r>', 'V', { desc = '<c-r> is new V in visual (remark visually)' })
    vim.keymap.set('n', 'R', '<C-v>', { desc = 'R is new <C-v> (remark visually)' })
    vim.keymap.set('x', 'R', '<C-v>', { desc = 'R is new <C-v> in visual (remark visually)' })
    vim.keymap.set({ 'n', 'x' }, 'v', 'r', { desc = 'v is the new r (also V, c-v) -> oVerwrite' })
    vim.keymap.set({ 'n', 'x' }, 'V', 'R', { desc = 'v is the new r (also V, c-v) -> oVerwrite' })
    vim.keymap.set({ 'n', 'x' }, '<c-v>', '<c-r>', { desc = 'v is the new r (also V, c-v) -> oVerwrite' })

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
