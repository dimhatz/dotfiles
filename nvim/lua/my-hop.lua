local remap = require('my-helpers').remap

return {
  'smoka7/hop.nvim',
  -- alternative: mini.jump2d in case this does not work well, this one does not support visual
  version = '*',
  config = function()
    local hop = require('hop')
    hop.setup({
      jump_on_sole_occurrence = false,
      uppercase_labels = true,
      multi_windows = false,
      create_hl_autocmd = true,
      -- keys = 'ASDGHKLQWERTYUIOPZXCVBNMFJ;',
    })
    local hint = require('hop.hint')

    -- remap('n', '<Leader>w', '<Cmd>HopWordAC<CR>') -- old mapping
    remap('n', 'f', function()
      hop.hint_words({ direction = hint.HintDirection.AFTER_CURSOR })
    end, { desc = 'Hop to [F]ollowing words' })
    remap('v', 'f', function()
      hop.hint_words({ direction = hint.HintDirection.AFTER_CURSOR })
    end, { desc = 'Hop to [F]ollowing words' })

    -- remap('n', '<Leader>b', '<Cmd>HopWordBC<CR>') -- old mapping
    remap('n', 't', function()
      hop.hint_words({ direction = hint.HintDirection.BEFORE_CURSOR })
    end, { desc = 'Hop to words before (torwards top)' })
    remap('v', 't', function()
      hop.hint_words({ direction = hint.HintDirection.BEFORE_CURSOR })
    end, { desc = 'Hop to words before (torwards top)' })

    -- WARN: do not remap to "composite" keys that start with <Leader>e, e.g.
    -- remap('n', '<Leader>ef' ...) <-- this will cause a timeout before our "more direct" remap is triggered
    remap('n', '<Leader>e', function()
      hop.hint_words({ direction = hint.HintDirection.AFTER_CURSOR, hint_position = hint.HintPosition.END })
    end, { desc = 'Hop to following words [E]nds' })
    remap('v', '<Leader>e', function()
      hop.hint_words({ direction = hint.HintDirection.AFTER_CURSOR, hint_position = hint.HintPosition.END })
    end, { desc = 'Hop to following words [E]nds' })

    remap('n', '<Leader>k', function()
      hop.hint_lines_skip_whitespace({ direction = hint.HintDirection.BEFORE_CURSOR })
    end, { desc = 'Hop to lines up - [K] motion' })
    remap('v', '<Leader>k', function()
      hop.hint_lines_skip_whitespace({ direction = hint.HintDirection.BEFORE_CURSOR })
    end, { desc = 'Hop to lines up - [K] motion' })

    remap('n', '<Leader>j', function()
      hop.hint_lines_skip_whitespace({ direction = hint.HintDirection.AFTER_CURSOR })
    end, { desc = 'Hop to lines down - [J] motion' })
    remap('v', '<Leader>j', function()
      hop.hint_lines_skip_whitespace({ direction = hint.HintDirection.AFTER_CURSOR })
    end, { desc = 'Hop to lines down - [J] motion' })
  end,
}
