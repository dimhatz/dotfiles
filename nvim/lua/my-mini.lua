local remap = require('my-helpers').remap
local log_my_error = require('my-helpers').log_my_error
-- # # TODO  <-- this should be normal
-- # # TODO: <-- this should be bold
return {
  'echasnovski/mini.nvim',
  lazy = false,
  priority = 1000,
  dependencies = {
    'willothy/nvim-cokeline', -- to manually restore buffer order
  },
  config = function()
    local session_file = '.nvim_session'

    local function save_cokeline_buffer_order()
      local ok_cokeline_buffers, buffers_lib = pcall(require, 'cokeline.buffers')
      if not ok_cokeline_buffers then
        log_my_error('My: cokeline.buffers not found. Not saving buffer order.')
        return
      end
      local valid_buffers = buffers_lib.get_valid_buffers()
      local file_paths = {}
      for _, buf in ipairs(valid_buffers) do
        table.insert(file_paths, buf.path)
      end
      local file_paths_json = vim.json.encode(file_paths)

      if string.find(file_paths_json, "'") then
        -- we will be appending a line like: let g:my_buf_order = '["path1", "path2"]'
        log_my_error("My: Found filename containing quote ('). Not saving buffer order.")
        return
      end

      if vim.fn.filewritable(session_file) ~= 1 then
        vim.print('My: No session file found. Not saving buffer order.')
        return
      end

      vim.fn.writefile({ '', "let g:my_buf_order = '" .. file_paths_json .. "'" }, session_file, 'a')
    end

    local function restore_cokeline_buffer_order()
      local ok_cokeline_buffers, buffers_lib = pcall(require, 'cokeline.buffers')
      if not ok_cokeline_buffers then
        vim.notify('My: cokeline.buffers not found. Not restoring buffer order.', vim.log.levels.WARN)
        return
      end
      local json = vim.g.my_buf_order
      if not json then
        vim.notify('My: cokeline.buffers global not found. Not restoring buffer order.', vim.log.levels.WARN)
        return
      end
      local file_paths = vim.json.decode(json)
      -- vim.print(file_paths)
      for i, file_path in ipairs(file_paths) do
        local buffers = buffers_lib.get_valid_buffers() -- get the fresh list every time
        for _, buffer in ipairs(buffers) do
          if i <= #buffers and buffer.path == file_path then
            -- vim.print('moving ' .. file_path .. ' from ' .. buffer._valid_index .. ' to ' .. i)
            buffers_lib.move_buffer(buffer, i)
          end
        end
      end
      vim.opt.tabline = cokeline.tabline() -- force refresh, this is global cokeline
      vim.print('My: buffer order restored.')
    end

    ---------------------------------------------------------------------------------------
    -- sessions plugin first, so that its autocmds have priority over the next mini.* plugins, like minimap
    require('mini.sessions').setup({
      autoread = true,
      autowrite = true,
      file = session_file, -- local session file
      directory = '', -- directory for global sessions, we disable it
      hooks = {
        post = {
          write = save_cokeline_buffer_order,
          read = function()
            log_my_error('start logging', true)
          end,
        },
      },
    })

    vim.api.nvim_create_autocmd('UIEnter', {
      group = vim.api.nvim_create_augroup('my-session-init', {}),
      desc = 'write session file in cwd if not exists',
      callback = function()
        -- triggers after the post-read hook of mini.sessions, but still needs timer, otherwise cokeline is not fully initialized and produces an error
        vim.fn.timer_start(0, restore_cokeline_buffer_order)
        -- restore_cokeline_buffer_order()
        if vim.fn.filereadable(session_file) ~= 0 then
          vim.print('My: Session found.')
          return
        end
        require('mini.sessions').write(session_file, { force = false, verbose = true })
      end,
    })

    ---------------------------------------------------------------------------------------

    -- Better Around/Inside textobjects
    -- Auto-jumps to next text object: to jump+visual inside next parens: vi)
    -- For larger scrope, press i) again
    require('mini.ai').setup({ n_lines = 500 }) -- 50 default, 500 suggested by kickstart

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
    })

    remap('n', 'sw', 'siw', { remap = true }) -- be consistent with cw -> ciw

    ---------------------------------------------------------------------------------------

    -- TODO: replace with something fully customizable, e.g. feline (that also has tabline), rebelot/heirline.nvim (even
    -- more customizable? manually set update triggers), tamton-aquib/staline.nvim also seems good
    local statusline = require('mini.statusline')
    statusline.setup({
      use_icons = vim.g.have_nerd_font,

      -- Whether to set Vim's settings for statusline (make it always shown with
      -- 'laststatus' set to 2). To use global statusline in Neovim>=0.7.0, set
      -- this to `false` and 'laststatus' to 3.
      set_vim_settings = true,
      content = {
        -- default config copied from helpfile
        active = function()
          local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 9999 }) -- our change: always trunc
          local git = MiniStatusline.section_git({ trunc_width = 75 })
          local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
          local filename = MiniStatusline.section_filename({ trunc_width = 140 })
          local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
          local location = MiniStatusline.section_location({ trunc_width = 75 })
          local search = MiniStatusline.section_searchcount({ trunc_width = 75 })

          return MiniStatusline.combine_groups({
            { hl = mode_hl, strings = { mode } },
            { hl = 'MiniStatuslineDevinfo', strings = { git, diagnostics } },
            '%<', -- Mark general truncate point
            { hl = 'MiniStatuslineFilename', strings = { filename } },
            '%=', -- End left alignment
            { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
            { hl = mode_hl, strings = { search, location } },
          })
        end,
        inactive = nil,
      },
    })

    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.section_location = function()
      return '%-3v'
    end

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

    local mini_bufremove = require('mini.bufremove')
    mini_bufremove.setup({})
    -- when closing with bdelete, with this plugin, the current window remains open
    remap('n', '<C-c>', mini_bufremove.delete, { desc = 'Close buffer' })

    ---------------------------------------------------------------------------------------
  end,
}
