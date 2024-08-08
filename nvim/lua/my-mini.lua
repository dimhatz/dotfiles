local remap = require('my-helpers').remap

return {
  'echasnovski/mini.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    ---------------------------------------------------------------------------------------
    -- sessions plugin first, so that its autocmds have priority over the next mini.* plugins, like minimap
    require('my-mini-sessions')
    ---------------------------------------------------------------------------------------

    -- Better Around/Inside textobjects
    -- Auto-jumps to next text object: to jump+visual inside next parens: vi)
    -- For larger scope, press i) again
    require('mini.ai').setup({ n_lines = 500 }) -- 50 default, 500 suggested by kickstart

    ---------------------------------------------------------------------------------------
    require('mini.operators').setup({
      exchange = {
        -- the only one we use, the rest are disabled through empty mappings
        prefix = '<C-x>',
        reindent_linewise = false,
      },
      evaluate = {
        prefix = '',
      },
      multiply = {
        prefix = '',
      },
      replace = {
        prefix = '',
      },
      sort = {
        prefix = '',
      },
    })

    -- note the extra ">" in rhs
    remap('n', '<C-x><C-x>', '<C-x>>', { remap = true, desc = 'Exchange line' })
    ---------------------------------------------------------------------------------------

    require('mini.surround').setup({
      mappings = {
        add = 's', -- Add surrounding in Normal and Visual modes
        delete = 'sd', -- Delete surrounding
        find = 'sf', -- Find surrounding (to the right)
        find_left = 'sF', -- Find surrounding (to the left)
        highlight = 'sh', -- Highlight surrounding
        replace = 'sc', -- Replace surrounding
        update_n_lines = 'su', -- Update `n_lines` (how many lines are searched to perform surround actions)
        suffix_last = 'l', -- Suffix to search with "prev" method
        suffix_next = 'n', -- Suffix to search with "next" method
      },
      n_lines = 100,
    })

    remap('n', 'sw', 'siw', { remap = true }) -- be consistent with cw -> ciw

    ---------------------------------------------------------------------------------------
    require('mini.indentscope').setup({
      symbol = '│', -- center(│), left (▏)
      draw = {
        delay = 20,
        animation = require('mini.indentscope').gen_animation.none(),
      },
    })

    ---------------------------------------------------------------------------------------

    -- autoclose brackets
    require('mini.pairs').setup({})

    ---------------------------------------------------------------------------------------

    local mini_map = require('mini.map')
    mini_map.setup({
      symbols = {
        -- left aligned (from indent-blankline's help) -- ▏-- ▎ -- ▍ -- ▌ --  ▋ --
        scroll_line = '►', --  -- ▶ -- ▸ -- ◆ -- ►
        scroll_view = '▋',
        -- if encode_strings() hack below stops working:
        -- encode = { '▐', '▐', resolution = { row = 1, col = 1 } },
      },
      window = {
        width = 2,
        winblend = 0,
        -- show_integration_count=true shows count 2+ even if there is just git add + git change
        -- not a reliable way to signify that there is also an error
        show_integration_count = false,
      },
      integrations = {
        mini_map.gen_integration.builtin_search({ search = 'MyMiniMapSearch' }),
        mini_map.gen_integration.diagnostic({
          error = 'MyMiniMapDiagError',
          warn = 'MyMiniMapDiagWarn',
          info = 'MyMiniMapDiagWarn',
          hint = 'MyMiniMapDiagWarn',
        }),
        mini_map.gen_integration.gitsigns({
          add = 'MyMiniMapAdded',
          change = 'MyMiniMapChanged',
          delete = 'MyMiniMapDeleted',
        }),
      },
    })

    -- local f = 1 -- for testing
    -- x = 3 -- for testing
    -- if this ever breaks: set symbols.encode = { '▐', '▐', resolution = { row = 1, col = 1 } },
    -- otherwise, it should be slightly more performant (not sure if in practice makes any difference)
    ---@diagnostic disable-next-line: duplicate-set-field
    mini_map.encode_strings = function(strings)
      -- return dummy table of empty strings, of equal length as the argument
      local res = {}
      local placeholder = '▐' -- ▐ --- │ --- █ -- 
      for _ = 1, #strings do
        table.insert(res, placeholder)
      end
      return res
    end

    -- vim.api.nvim_create_autocmd('UIEnter', { -- works
    -- vim.api.nvim_create_autocmd('SessionLoadPost', { -- works
    vim.api.nvim_create_autocmd('VimEnter', {
      group = vim.api.nvim_create_augroup('my-minimap-run', {}),
      desc = 'Run mini.map on startup',
      callback = function()
        mini_map.open()
      end,
    })

    vim.api.nvim_create_autocmd('ExitPre', {
      group = vim.api.nvim_create_augroup('my-minimap-exit-before-session-save', {}),
      desc = 'Exit minimap before session save, otherwise resized splits are not preserved',
      callback = function()
        -- TODO: when restoring session with a resized split, if we dont quit minimap
        -- before saving session, the restored windows will take half the screen,
        -- instead of having width = 90
        -- NOTE: minisessions triggers on VimLeavePre, which is after this autocmd
        mini_map.close()
      end,
    })

    require('mycolors').apply_colors_minimap()

    ---------------------------------------------------------------------------------------

    require('my-undo-delete-buffer')
    local mini_bufremove = require('mini.bufremove')
    mini_bufremove.setup({})
    -- when closing with bdelete, with this plugin, the current window remains open
    remap('n', '<C-c>', mini_bufremove.delete, { desc = 'Close buffer' })

    ---------------------------------------------------------------------------------------
  end,
}
