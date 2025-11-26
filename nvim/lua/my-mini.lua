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
    require('mini.extra').setup({})
    -- Better Around/Inside textobjects
    -- Auto-jumps to next text object: to jump+visual inside next parens: vi)
    -- For larger scope, press i) again
    require('mini.ai').setup({
      silent = true,
      n_lines = 500, -- 50 default, 500 suggested by kickstart
      search_method = 'cover',
      mappings = {
        around = '.',
        inside = ',',
        around_next = '',
        inside_next = '',
        around_last = '',
        inside_last = '',
      },
      custom_textobjects = {
        -- e for entire
        e = MiniExtra.gen_ai_spec.buffer(),
      },
    })

    -- local better_visual_repeat = require('better-visual-repeat')
    -- local mini_ai_i_mapargs = vim.fn.maparg(',', 'v', false, true)
    -- remap('x', ',', function()
    --   better_visual_repeat.force_alive(true)
    --   vim.schedule(function()
    --     better_visual_repeat.force_alive(false)
    --   end)
    --   return mini_ai_i_mapargs.callback()
    -- end, { expr = true, desc = 'Make moves like ,) repeatable with better-visual-repeat' })
    --
    -- local mini_ai_a_mapargs = vim.fn.maparg('.', 'v', false, true)
    -- remap('x', '.', function()
    --   better_visual_repeat.force_alive(true)
    --   vim.schedule(function()
    --     better_visual_repeat.force_alive(false)
    --   end)
    --   return mini_ai_a_mapargs.callback()
    -- end, { expr = true, desc = 'Make moves like .) repeatable with better-visual-repeat' })

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
        add = 'c', -- Add surrounding in Normal and Visual modes
        delete = 'cd', -- Delete surrounding
        find = 'cf', -- Find surrounding (to the right)
        find_left = 'cF', -- Find surrounding (to the left)
        highlight = 'ch', -- Highlight surrounding
        replace = 'cr', -- Replace surrounding
        update_n_lines = 'cu', -- Update `n_lines` (how many lines are searched to perform surround actions)
        suffix_last = 'l', -- Suffix to search with "prev" method
        suffix_next = 'n', -- Suffix to search with "next" method
      },
      n_lines = 100,
      silent = true,
    })

    remap('n', 'cw', 'ciw', { remap = true, desc = 'contour, cloak, circumscribe (surround) inside word' }) -- be consistent with dw -> diw
    remap({ 'n', 'x' }, 's', '"_c', { desc = 'substitute, supersede, supplant (change)' })
    remap('n', 'S', '"_C')

    -- vim.api.nvim_del_keymap('x', 's')
    -- local visual_surround = require('my-visual-surround').visual_surround
    -- remap('x', 's', visual_surround, { desc = 'My custom surround that works with my visual repeat' })

    ---------------------------------------------------------------------------------------
    require('mini.indentscope').setup({
      symbol = '│', -- center(│), left (▏)
      draw = {
        delay = 64,
        animation = require('mini.indentscope').gen_animation.none(),
      },
      mappings = {
        -- Textobjects
        object_scope = ',i', -- inside indent
        object_scope_with_border = '.i', -- around indent

        -- Motions (jump to respective border line; if not present - body line)
        goto_top = 'ga',
        goto_bottom = 'gi',
      },
    })
    -- -- TODO: do not allow indentscope to overwrite visual mappings i, a
    -- remap(
    --   'x',
    --   ',i',
    --   '<Cmd>lua BetterVisualRepeat.force_alive(true); MiniIndentscope.textobject(false); BetterVisualRepeat.force_alive(false)<CR>',
    --   { desc = 'Override mini.indentscope ii to work with our visual repeat' }
    -- )
    --
    -- remap(
    --   'x',
    --   '.i',
    --   '<Cmd>lua BetterVisualRepeat.force_alive(true); MiniIndentscope.textobject(true); BetterVisualRepeat.force_alive(false)<CR>',
    --   { desc = 'Override mini.indentscope ai to work with our visual repeat' }
    -- )

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

    -- NOTE: mini.sessions autocmds are registered inside my-mini-sessions.lua to avoid
    -- undesired behavior.

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
