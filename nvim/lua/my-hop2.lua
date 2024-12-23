local remap = require('my-helpers').remap

local HintPosition = {
  BEGIN = 1,
  MIDDLE = 2,
  END = 3,
}

local defaults = {
  keys = 'asdghklqwertyuiopzxcvbnmfj',
  quit_key = '<Esc>',
  perm_method = require('hop.perm').TrieBacktrackFilling,
  reverse_distribution = false,
  x_bias = 10,
  distance_method = hint.manh_distance,
  teasing = true,
  virtual_cursor = false,
  jump_on_sole_occurrence = true,
  case_insensitive = true,
  create_hl_autocmd = true,
  current_line_only = false,
  dim_unmatched = true,
  hl_mode = 'combine',
  uppercase_labels = false,
  multi_windows = false,
  windows_list = function()
    return vim.api.nvim_tabpage_list_wins(0)
  end,
  ignore_injections = false,
  hint_position = HintPosition.BEGIN, -- @type HintPosition,
  hint_offset = 0, -- @type WindowCell,
  hint_type = hint.HintType.OVERLAY, -- @type HintType,
  excluded_filetypes = {},
  match_mappings = {},
  extensions = { 'hop-yank', 'hop-treesitter' },
}

HintDirection = {
  BEFORE_CURSOR = 1,
  AFTER_CURSOR = 2,
}
local initialized = true
local local_opts = {}
-- Setup user settings.
local function setup(opts_arg)
  -- Look up keys in user-defined table with fallback to defaults.
  local_opts = setmetatable(opts_arg or {}, { __index = require('hop.defaults') })
  initialized = true

  -- Insert the highlights and register the autocommand if asked to.
  local highlight = require('hop.highlight')
  highlight.insert_highlights()

  if local_opts.create_hl_autocmd then
    highlight.create_autocmd()
  end
end

setup({
  jump_on_sole_occurrence = false,
  uppercase_labels = true,
  multi_windows = false,
  create_hl_autocmd = true,
  -- keys = 'ASDGHKLQWERTYUIOPZXCVBNMFJ;',
})

-- Move the cursor to a given location.
-- This function will update the jump list.
-- @param jt JumpTarget
-- @param opts Options Add option to shift cursor by column offset
local function move_cursor_to(jt, opts)
  local jump_target = require('hop.jump_target')

  -- If it is pending for operator shift pos.col to the right by 1
  if vim.api.nvim_get_mode().mode == 'no' and opts.direction ~= HintDirection.BEFORE_CURSOR then
    jt.cursor.col = jt.cursor.col + 1
  end

  jump_target.move_jump_target(jt, 0, opts.hint_offset)

  -- Update the jump list
  -- There is bug with set extmark neovim/neovim#17861
  vim.api.nvim_set_current_win(jt.window)
  --local cursor = api.nvim_win_get_cursor(0)
  --api.nvim_buf_set_mark(jt.buffer, "'", cursor[1], cursor[2], {})
  vim.cmd("normal! m'")
  vim.api.nvim_win_set_cursor(jt.window, { jt.cursor.row, jt.cursor.col })
end

-- Get information about the window and the cursor
-- @param win_handle number
-- @param buf_handle number
-- @return WindowContext
local function window_context(win_handle, buf_handle)
  local win_info = vim.fn.getwininfo(win_handle)[1]
  local win_view = vim.api.nvim_win_call(win_handle, vim.fn.winsaveview)
  local cursor_pos = vim.api.nvim_win_get_cursor(win_handle)
  local cursor = { row = cursor_pos[1], col = cursor_pos[2] }

  local bottom_line = vim.api.nvim_buf_get_lines(buf_handle, win_info.botline - 1, win_info.botline, false)[1]
  local right_column = string.len(bottom_line)

  local win_width = nil
  if not vim.wo.wrap then
    --number of columns occupied by any	'foldcolumn', 'signcolumn' and line number in front of the text
    win_width = win_info.width - win_info.textoff
  end

  local cursor_line = vim.api.nvim_buf_get_lines(buf_handle, cursor.row - 1, cursor.row, false)[1]
  local col_first = vim.fn.strdisplaywidth(cursor_line:sub(1, cursor.col)) - win_view.leftcol

  return {
    win_handle = win_handle,
    buf_handle = buf_handle,
    cursor = cursor,
    line_range = { win_info.topline, win_info.botline },
    column_range = { 0, right_column },
    win_width = win_width,
    col_offset = win_view.leftcol,
    col_first = col_first,
  }
end

-- Get all windows context
-- @param opts Options
-- @return WindowContext[] The first is always current window
local function get_windows_context(opts)
  -- @type WindowContext[]
  local contexts = {}

  -- Generate contexts of windows
  local cur_hwin = vim.api.nvim_get_current_win()
  local cur_hbuf = vim.api.nvim_win_get_buf(cur_hwin)

  contexts[1] = window_context(cur_hwin, cur_hbuf)

  if not opts.multi_windows then
    return contexts
  end

  -- Get the context for all the windows in current tab
  for _, w in ipairs(opts.windows_list()) do
    local valid_win = vim.api.nvim_win_is_valid(w)
    local focusable_win = vim.api.nvim_win_get_config(w).focusable
    if valid_win and focusable_win and w ~= cur_hwin then
      local b = vim.api.nvim_win_get_buf(w)

      -- Skips current window and excluded filetypes
      if not (vim.tbl_contains(opts.excluded_filetypes, vim.bo[b].filetype)) then
        contexts[#contexts + 1] = window_context(w, b)
      end
    end
  end

  return contexts
end

-- Clip the window context area
-- @param win_ctx WindowContext
-- @param opts Options
local function clip_window_context(win_ctx, opts)
  local hint = require('hop.hint')

  local row = win_ctx.cursor.row
  local line = vim.api.nvim_buf_get_lines(win_ctx.buf_handle, row - 1, row, false)[1]

  if opts.current_line_only then
    win_ctx.line_range[1] = row
    win_ctx.line_range[2] = row
    win_ctx.column_range[1] = 0
    win_ctx.column_range[2] = string.len(line)
  end

  if opts.direction == hint.HintDirection.BEFORE_CURSOR then
    win_ctx.line_range[2] = win_ctx.cursor.row
    win_ctx.column_range[2] = win_ctx.cursor.col

    -- For non-empty lines we have to increment it so we include the cursor
    if #line > 0 then
      win_ctx.column_range[2] = win_ctx.cursor.col + 1
    end
  elseif opts.direction == hint.HintDirection.AFTER_CURSOR then
    win_ctx.line_range[1] = win_ctx.cursor.row
    win_ctx.column_range[1] = win_ctx.cursor.col
  end
end

-- Create hint state
-- @param opts Options
-- @return HintState
local function create_hint_state(opts)
  -- @type HintState
  local hint_state = {}

  hint_state.all_ctxs = get_windows_context(opts)
  hint_state.buf_list = {}
  local buf_sets = {}
  for _, wctx in ipairs(hint_state.all_ctxs) do
    if not buf_sets[wctx.buf_handle] then
      buf_sets[wctx.buf_handle] = true
      hint_state.buf_list[#hint_state.buf_list + 1] = wctx.buf_handle
    end
    -- Ensure all window contexts are cliped for hint state
    clip_window_context(wctx, opts)
  end

  -- Create the highlight groups; the highlight groups will allow us to clean everything at once when Hop quits
  hint_state.hl_ns = vim.api.nvim_create_namespace('hop_hl')
  hint_state.dim_ns = vim.api.nvim_create_namespace('hop_dim')

  -- Clear namespaces in case last hop operation failed before quitting
  for _, buf in ipairs(hint_state.buf_list) do
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_clear_namespace(buf, hint_state.hl_ns, 0, -1)
      vim.api.nvim_buf_clear_namespace(buf, hint_state.dim_ns, 0, -1)
    end
  end

  -- Backup namespaces of diagnostic
  hint_state.diag_ns = vim.diagnostic.get_namespaces()

  return hint_state
end

-- Display error messages.
-- @param msg string
-- @param teasing boolean
local function eprintln(msg, teasing)
  if teasing then
    vim.api.nvim_echo({ { msg, 'Error' } }, true, {})
  end
end

-- @param buf_list number[] list of buffer handles
-- @param hl_ns number highlight namespace
local function clear_namespace(buf_list, hl_ns)
  for _, buf in ipairs(buf_list) do
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_clear_namespace(buf, hl_ns, 0, -1)
    end
  end
end

-- @param keys string
-- @param n number
-- @param opts Options
-- @return string[][]
local function permutations(keys, n, opts)
  return opts.perm_method:permutations(keys, n)
end

-- Create hints from jump targets.
--
-- This function associates jump targets with permutations, creating hints. A hint is then a jump target along with a
-- label.
--
-- If `indirect_jump_targets` is `nil`, `jump_targets` is assumed already ordered with all jump target with the same
-- score (0)
-- @param jump_targets JumpTarget[]
-- @param indirect_jump_targets IndirectJumpTarget[]
-- @param opts Options
-- @return Hint[]
local function create_hints(jump_targets, indirect_jump_targets, opts)
  local hints = {}
  local perms = permutations(opts.keys, #jump_targets, opts)

  -- get or generate indirect_jump_targets
  if indirect_jump_targets == nil then
    indirect_jump_targets = {}

    for i = 1, #jump_targets do
      indirect_jump_targets[i] = { index = i, score = 0 }
    end
  end

  for i, indirect in pairs(indirect_jump_targets) do
    hints[indirect.index] = {
      label = table.concat(perms[i]),
      jump_target = jump_targets[indirect.index],
    }
  end

  return hints
end

-- Add the virtual cursor, taking care to handle the cases where:
-- - the virtualedit option is being used and the cursor is in a
--   tab character or past the end of the line
-- - the current line is empty
-- - there are multibyte characters on the line
-- @param ns number
local function add_virt_cur(ns)
  local hint = require('hop.hint')

  local cur_info = vim.fn.getcurpos()
  local cur_row = cur_info[2] - 1
  local cur_col = cur_info[3] - 1 -- this gives cursor column location, in bytes
  local cur_offset = cur_info[4]
  local virt_col = cur_info[5] - 1
  local cur_line = vim.api.nvim_get_current_line()

  -- first check to see if cursor is in a tab char or past end of line or in empty line
  if cur_offset ~= 0 or #cur_line == cur_col then
    vim.api.nvim_buf_set_extmark(0, ns, cur_row, cur_col, {
      virt_text = { { '█', 'Normal' } },
      virt_text_win_col = virt_col,
      priority = hint.HintPriority.CURSOR,
    })
  else
    vim.api.nvim_buf_set_extmark(0, ns, cur_row, cur_col, {
      -- end_col must be column of next character, in bytes
      end_col = vim.fn.byteidx(cur_line, vim.fn.charidx(cur_line, cur_col) + 1),
      hl_group = 'HopCursor',
      priority = hint.HintPriority.CURSOR,
    })
  end
end

--- verify that column value is always smaller than line length
-- @param wctx WindowContext
local function sanitize_cols(wctx)
  local start_line = vim.api.nvim_buf_get_lines(wctx.buf_handle, wctx.line_range[1], wctx.line_range[1] + 1, false)
  if #start_line < wctx.column_range[1] then
    wctx.column_range[1] = #start_line
  end
  local end_line = vim.api.nvim_buf_get_lines(wctx.buf_handle, wctx.line_range[2], wctx.line_range[2] + 1, false)
  if #end_line < wctx.column_range[2] then
    wctx.column_range[2] = #end_line
  end
end

-- Dim everything out to prepare the hop session for all windows
-- @param hint_state HintState
-- @param opts Options
local function apply_dimming(hint_state, opts)
  local hint = require('hop.hint')
  local window = require('hop.window')

  if not opts.dim_unmatched then
    return
  end

  for _, wctx in ipairs(hint_state.all_ctxs) do
    -- Set the highlight of unmatched lines of the buffer.
    sanitize_cols(wctx)
    local start_line, end_line = window.line_range2extmark(wctx.line_range)
    local start_col, end_col = window.column_range2extmark(wctx.column_range)
    vim.api.nvim_buf_set_extmark(wctx.buf_handle, hint_state.dim_ns, start_line, start_col, {
      end_line = end_line,
      end_col = end_col,
      hl_group = 'HopUnmatched',
      hl_eol = true,
      priority = hint.HintPriority.DIM,
    })

    -- Hide diagnostics
    for ns in pairs(hint_state.diag_ns) do
      vim.diagnostic.show(ns, wctx.buf_handle, nil, { virtual_text = false })
    end
  end

  -- Add the virtual cursor
  if opts.virtual_cursor then
    add_virt_cur(hint_state.hl_ns)
  end
end

local HintPriority = {
  DIM = 65533,
  HINT = 65534,
  CURSOR = 65535,
}

-- Convert CursorPos to extmark position
-- @param pos CursorPos
local function pos2extmark(pos)
  return pos.row - 1, pos.col
end

-- Create the extmarks for per-line hints.
-- @param hl_ns integer
-- @param hints Hint[]
-- @param opts Options
local function set_hint_extmarks(hl_ns, hints, opts)
  for _, hint in pairs(hints) do
    local label = hint.label
    if opts.uppercase_labels and label ~= nil then
      label = label:upper()
    end

    local virt_text = { { label, 'HopNextKey' } }
    -- Get the byte index of the second hint so that we can slice it correctly
    if label ~= nil and vim.fn.strdisplaywidth(label) ~= 1 then
      local snd_idx = vim.fn.byteidx(label, 1)
      virt_text = { { label:sub(1, snd_idx), 'HopNextKey1' }, { label:sub(snd_idx + 1), 'HopNextKey2' } }
    end

    local row, col = pos2extmark(hint.jump_target.cursor)
    vim.api.nvim_buf_set_extmark(hint.jump_target.buffer, hl_ns, row, col, {
      virt_text = virt_text,
      virt_text_pos = opts.hint_type,
      hl_mode = opts.hl_mode,
      priority = HintPriority.HINT,
    })
  end
end

-- Quit Hop and delete its resources.
-- @param hint_state HintState
local function quit(hint_state)
  clear_namespace(hint_state.buf_list, hint_state.hl_ns)
  clear_namespace(hint_state.buf_list, hint_state.dim_ns)

  for _, buf in ipairs(hint_state.buf_list) do
    -- sometimes, buffers might be unloaded; that’s the case with floats for instance (we can invoke Hop from them but
    -- then they disappear); we need to check whether the buffer is still valid before trying to do anything else with
    -- it
    if vim.api.nvim_buf_is_valid(buf) then
      for ns in pairs(hint_state.diag_ns) do
        vim.diagnostic.show(ns, buf)
      end
    end
  end
end

-- Refine hints in the given buffer.
--
-- Refining hints allows to advance the state machine by one step. If a terminal step is reached, this function jumps to
-- the location. Otherwise, it stores the new state machine.
local function refine_hints(key, hint_state, callback, opts)
  local hint = require('hop.hint')

  local h, hints = hint.reduce_hints(hint_state.hints, key)

  if h == nil then
    if #hints == 0 then
      eprintln('no remaining sequence starts with ' .. key, opts.teasing)
      return
    end

    hint_state.hints = hints

    clear_namespace(hint_state.buf_list, hint_state.hl_ns)
    hint.set_hint_extmarks(hint_state.hl_ns, hints, opts)
  else
    quit(hint_state)

    callback(h.jump_target)
    return h
  end
end

-- @param jump_target_gtr function
-- @param opts Options
-- @param callback function
local function hint_with_callback(jump_target_gtr, opts, callback)
  if not initialized then
    vim.notify('Hop is not initialized; please call the setup function', vim.log.levels.ERROR)
    return
  end

  -- create hint state
  local hs = create_hint_state(opts)

  -- create jump targets
  local generated = jump_target_gtr(opts, hs.all_ctxs)
  local jump_target_count = #generated.jump_targets

  local target_idx = nil
  if jump_target_count == 0 then
    target_idx = 0
  elseif vim.v.count > 0 then
    target_idx = vim.v.count
  elseif jump_target_count == 1 and opts.jump_on_sole_occurrence then
    target_idx = 1
  end

  if target_idx ~= nil then
    local jt = generated.jump_targets[target_idx]
    if jt then
      callback(jt)
    else
      eprintln(' -> there’s no such thing we can see…', opts.teasing)
    end

    clear_namespace(hs.buf_list, hs.hl_ns)
    clear_namespace(hs.buf_list, hs.dim_ns)
    return
  end

  -- we have at least two targets, so generate hints to display
  hs.hints = create_hints(generated.jump_targets, generated.indirect_jump_targets, opts)

  apply_dimming(hs, opts)
  set_hint_extmarks(hs.hl_ns, hs.hints, opts)
  vim.cmd.redraw()

  local h = nil
  while h == nil do
    local ok, key = pcall(vim.fn.getcharstr)
    if not ok then
      quit(hs)
      break
    end

    -- Special keys are string and start with 128 see :h getchar
    local not_special_key = true
    if key and key:byte() == 128 then
      not_special_key = false
    end

    -- If this is a key used in Hop (via opts.keys), deal with it in Hop
    -- otherwise quit Hop
    if not_special_key and opts.keys:find(key, 1, true) then
      h = refine_hints(key, hs, callback, opts)
      vim.cmd.redraw()
    else
      quit(hs)
      -- If the captured key is not the quit_key, pass it through
      -- to nvim to be handled normally (including mappings)
      if key ~= vim.api.nvim_replace_termcodes(opts.quit_key, true, false, true) then
        vim.api.nvim_feedkeys(key, '', true)
      end
      break
    end
  end
end

-- @param regex Regex
-- @param opts Options
-- @param callback function|nil
local function hint_with_regex(regex, opts, callback)
  local jump_target = require('hop.jump_target')

  local jump_target_gtr = jump_target.jump_target_generator(regex)

  hint_with_callback(jump_target_gtr, opts, callback or function(jt)
    move_cursor_to(jt, opts)
  end)
end

local function hint_words(opts)
  local jump_regex = require('hop.jump_regex')

  hint_with_regex(jump_regex.regex_by_word_start(), opts)
end

remap('n', 'F', function()
  hint_words({ direction = HintDirection.AFTER_CURSOR })
end, { desc = 'Hop to [F]ollowing words' })
