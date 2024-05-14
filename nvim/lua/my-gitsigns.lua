local remap = require('my-helpers').remap

return {
  'lewis6991/gitsigns.nvim',
  opts = {
    signs = { -- faded -- ▒
      -- left aligned (from indent-blankline's help) -- ▏-- ▎ -- ▍ -- ▌ --  ▋ --
      add = { text = '▎' },
      change = { text = '▎' },
      delete = { text = '▎' },
      topdelete = { text = '▎' },
      changedelete = { text = '▎' },
    },
    on_attach = function()
      local gitsigns = require('gitsigns')
      remap('n', '<Leader>gr', gitsigns.reset_hunk, { desc = '[G]itsigns [R]eset hunk' })
      remap('n', 'gh', gitsigns.preview_hunk, { desc = '[G]itsigns preview [H]unk' })
      -- remap('n', 'gi', gitsigns.preview_hunk_inline, { desc = '[G]itsigns preview hunk [I]nline' })
      remap('n', 'gn', function()
        if vim.wo.diff then
          vim.cmd.normal({ ']c', bang = true })
        else
          gitsigns.nav_hunk('next')
        end
      end, { desc = '[G]itsigns go to [N]ext hunk' })

      remap('n', 'gp', function()
        if vim.wo.diff then
          vim.cmd.normal({ '[c', bang = true })
        else
          gitsigns.nav_hunk('prev')
        end
      end, { desc = '[G]itsigns go to [P]revious hunk' })
    end,
  },
}
