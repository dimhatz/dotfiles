-- Better name: 'repeat last visual edit': here (normal) / on current selection'
local M = {}
local remap = require('my-helpers').remap
local slice_array = require('my-helpers').slice_array
local simulate_keys = require('my-helpers').simulate_keys

local cl = require('my-helpers').create_cond_logger('Log_my_visual_repeat')
Log_my_visual_repeat = false -- help autocomplete when manually overriding to true
My_visual_repeat_force_alive = My_visual_repeat_force_alive or false

local visual_repeat_is_recording = false --- to differentiate from regular macro recording
local changed_tick_start = 0
-- must store visual_mode, we cannot rely on vim.fn.visualmode()
-- since there could be a visual block with no change, before our (valid) repeat is called.
local visual_mode = 'v'
local last_valid_macro = ''
local MY_MACRO_REGISTER = 'v' -- used to record the macro
local MY_MACRO_REGISTER2 = 'z' -- used to replay the macro with an existing selection (while in visual)
local mappings_that_edit_in_visual = { 'm', 'x', 'X', 'd', 'D', 'c', 'p', 'r', 'gc', 's', '>', '<', 'U' }

_G.My_visual_noop = function() end

-- @param motion: when called the first time by us, will be nil
-- when called as a repeat (g@l) by nvim, will be set to 'char' (see :h g@)
_G.My_visual_repeat = function(motion)
  cl('got motion:', motion)
  if motion == nil then
    cl('first call')
    visual_repeat_is_recording = true
    changed_tick_start = vim.api.nvim_buf_get_var(0, 'changedtick')
    vim.cmd('normal! qv' .. visual_mode)
    return
  end

  -- this is repeat by .
  cl('repeat call is valid')
  vim.fn.setreg(MY_MACRO_REGISTER, last_valid_macro)
  vim.cmd('normal! ' .. visual_mode .. '@' .. MY_MACRO_REGISTER) -- :normal! v@v
  -- needed so that a second (consequtive) . repeats g@l instead of doing regular repeat
  vim.go.operatorfunc = 'v:lua.My_visual_noop'
  vim.cmd('normal! g@l')
  vim.go.operatorfunc = 'v:lua.My_visual_repeat'
end

-- operatorfunc examples:
-- https://gist.github.com/kylechui/a5c1258cd2d86755f97b10fc921315c3
-- https://www.vikasraj.dev/blog/vim-dot-repeat
remap('n', 'v', function()
  if vim.fn.reg_recording() ~= '' then
    -- regular recording ongoing
    cl('Regular recording ongoing')
    vim.cmd('normal! v')
    return
  end
  cl('start ' .. vim.api.nvim_buf_get_var(0, 'changedtick'))
  visual_mode = 'v'
  My_visual_repeat()
end, { desc = 'Start visual with repeat' })

remap('n', '<C-v>', function()
  if vim.fn.reg_recording() ~= '' then
    -- regular recording ongoing
    cl('Regular recording ongoing')
    vim.cmd('normal! V')
    return
  end
  cl('start ' .. vim.api.nvim_buf_get_var(0, 'changedtick'))
  visual_mode = 'V'
  My_visual_repeat()
end, { desc = 'Start linewise visual with repeat' })

-- TODO: handle escape sequences too? E.g. <C-c>, nvim_replace_termcodes will be needed.
-- ----- handle mappings that edit, but start with " , e.g. "_d
-- ----- check how timeout-based mappings are recorded -> answer without any special
-- <timeout> thing. When replayed, these act as super-quickly typed keys by user.
remap('x', '.', function()
  if last_valid_macro == '' or (vim.fn.reg_recording() ~= '' and not visual_repeat_is_recording) then
    return
  end
  local mode = vim.fn.mode(1)
  if mode ~= 'v' and mode ~= 'V' then
    return
  end

  My_visual_repeat_stop()

  -- find whichever of input_chars_that_edit_in_visual is first, note that some of them might
  -- be >1 chars
  local edit_char_idx = 0 -- zero for 'not found'

  for i = 1, #last_valid_macro do
    local macro_substring = last_valid_macro:sub(i)
    for _, mapping in ipairs(mappings_that_edit_in_visual) do
      if vim.startswith(macro_substring, mapping) then
        edit_char_idx = i
        break
      end
    end
    if edit_char_idx ~= 0 then
      break
    end
  end

  if edit_char_idx == 0 then
    vim.notify('Visual repeat: could not find the mapping that edits in the recorded macro: ' .. last_valid_macro, vim.log.levels.ERROR)
    return
  end

  local edit_part_of_macro = last_valid_macro:sub(edit_char_idx)
  vim.fn.setreg(MY_MACRO_REGISTER2, edit_part_of_macro)

  vim.cmd('normal! @' .. MY_MACRO_REGISTER2)
end, { desc = 'Repeat last visual edit on current selection' })

remap({ 'n', 'x' }, 'V', '<C-v>', { desc = 'V is the new visual block' })
remap('x', '<C-v>', 'V', { desc = '<C-v> is the new linewise visual' })
-- NOTE: there is no sense in recording gv, since reselection does not
-- store the original selection movements. This makes it impossible to
-- replay the actions following gv on the next lines.

-- global in case we need to call it from a mapping as a workaround
function My_visual_repeat_stop()
  My_visual_repeat_force_alive = false
  visual_repeat_is_recording = false

  if vim.fn.reg_recording() == '' then
    vim.notify('My visual repeat: expected that a macro is being recorded', vim.log.levels.ERROR)
    return
  end

  cl('Stopping rec')
  vim.cmd('normal! q')

  local changed_tick_current = vim.api.nvim_buf_get_var(0, 'changedtick')
  if changed_tick_current == changed_tick_start then
    -- no changes were made
    cl('invalidated due to no changes')
    local res = vim.fn.setreg(MY_MACRO_REGISTER, '') -- defensive
    if res ~= 0 then
      vim.notify('My visual repeat: could not set register (defensive)', vim.log.levels.ERROR)
    end
    return
  end

  -- at this point the recorded macro is valid and can be repeated
  vim.schedule(function()
    -- schedule is needed, otherwise just the last action is repeated, not our g@l
    cl('setting last cmd to our g@l')
    -- vim history has the individual edit as last, force it to be our g@l
    vim.go.operatorfunc = 'v:lua.My_visual_noop'
    vim.cmd('normal! g@l')
    vim.go.operatorfunc = 'v:lua.My_visual_repeat'
    last_valid_macro = vim.fn.getreg(MY_MACRO_REGISTER)
  end)
end

-- mini.surround's visual is mapped to [[:<C-u>MiniSurround.add('visual')<CR>]]
-- This causes exiting and re-entering visual, which is likely what mini.surround
-- wants to work with marks '> '<, that are buggy in vim and are not consistenly
-- updated unless exiting visual. This causes compatibility problem for us,
-- with no workaround with just mappings, since there is a user input function
-- that can take arbitrarily long amount of time to resolve.
-- Implementing our own visual surround is the solution.
function M.my_visual_surround()
  local mode = vim.fn.mode(1)
  -- vim.print('mode: ' .. mode)
  if mode ~= 'v' and mode ~= 'V' then
    return
  end
  local is_visual_line_mode = mode == 'V'
  local cursor_pos = slice_array(vim.fn.getpos('.'), 2, 4) ---@type [integer, integer] -- 1-based
  local other_side_pos = slice_array(vim.fn.getpos('v'), 2, 4) ---@type [integer, integer]
  local is_direction_forward = true -- cursor is before (<) than end of selection (top < bottom, left < right)
  local start_pos, end_pos = cursor_pos, other_side_pos -- cursor is at beginning of selection
  if cursor_pos[1] == other_side_pos[1] and cursor_pos[2] > other_side_pos[2] then
    is_direction_forward = false
  end
  if cursor_pos[1] > other_side_pos[1] then
    is_direction_forward = false
  end
  if not is_direction_forward then
    local temp = start_pos
    start_pos = end_pos
    end_pos = temp
  end

  cl('targets before adjusting for beyond eol: ', { start_pos, end_pos })
  -- NOTE: actual text insertion happens right _before_ the target column.
  local start_row_text = vim.fn.getline(start_pos[1])
  local end_row_text = vim.fn.getline(end_pos[1])
  if is_visual_line_mode then
    start_pos[2] = 1
    end_pos[2] = #end_row_text + 1
  else
    -- regular visual mode
    -- We need to account for the possibility that any or both positions' columns
    -- can be beyond eol.
    if start_pos[2] > #start_row_text + 1 then
      -- the start column gets capped at max_col + 1, since the
      -- actual insertion will happen before it
      start_pos[2] = #start_row_text + 1
    end

    if end_pos[2] > #end_row_text then
      -- the end column gets capped at max_col, this is like keeping
      -- cursor from going beyond eol.
      end_pos[2] = #end_row_text
    end
    -- additional offset for end_pos in all cases, since the actual insertion
    -- will happen before it, but we want the surrounding character to appear after it.
    end_pos[2] = end_pos[2] + 1
  end
  cl('targets after: ', { start_pos, end_pos })

  local pairs = { '()', '{}', '[]', '<>' }
  local char = vim.fn.getcharstr()
  if #char ~= 1 then
    vim.notify('My surround: length of char not 1', vim.log.levels.ERROR)
    return
  end
  local pair_to_insert = char .. char
  for _, pair_str in ipairs(pairs) do
    if pair_str:find(char, 1, true) then
      pair_to_insert = pair_str
      break
    end
  end

  local targets = { start_pos, end_pos } -- just to match with pairs
  for i = #targets, 1, -1 do
    -- reverse loop, since forward loop would shift text, altering positions
    local target = targets[i]
    -- 0-based
    local insert_row = target[1] - 1
    local insert_col = target[2] - 1
    cl('setting text to 0-based: ' .. insert_row .. ' ' .. insert_col)
    vim.api.nvim_buf_set_text(0, insert_row, insert_col, insert_row, insert_col, { pair_to_insert:sub(i, i) })
  end

  simulate_keys('<Esc>', 'nx') -- nx needed, otherwise gv will not select the desired region

  -- make gv select around the added symbol, so that another s + symbol can follow
  -- when on the same line, 2 chars have been added to the line, so the offset is 2
  local col_offset = targets[1][1] == targets[2][1] and 2 or 1
  vim.fn.setpos("'<", { 0, targets[1][1], targets[1][2], 0 })
  vim.fn.setpos("'>", { 0, targets[2][1], targets[2][2] + col_offset, 0 })
end

vim.api.nvim_create_autocmd({ 'ModeChanged' }, {
  desc = 'My: visual repeat update',
  group = vim.api.nvim_create_augroup('my-visual-repeat-modes', { clear = true }),
  callback = function()
    local old_mode = vim.v.event.old_mode
    local new_mode = vim.v.event.new_mode
    cl(old_mode .. ' ' .. new_mode .. ' ' .. vim.api.nvim_buf_get_var(0, 'changedtick'))

    if not visual_repeat_is_recording or My_visual_repeat_force_alive then
      return
    end
    -- cl('op: ' .. vim.v.operator)
    -- mode 'no' stands for normal operator pending, see :h mode()
    if new_mode == 'v' or new_mode == 'V' or new_mode == 'i' or new_mode == 'no' or old_mode == 'no' then
      -- do not cancel recording when switching between regular / line visual, or making changes
      return
    end

    -- we are out of visual now, so stopping recording
    My_visual_repeat_stop()
  end,
})

vim.api.nvim_create_autocmd({ 'RecordingLeave' }, {
  desc = 'My: visual repeat update',
  group = vim.api.nvim_create_augroup('my-visual-repeat-recording-leave', { clear = true }),
  callback = function()
    -- Edge case: the user presses q when we are recording
    -- at this point vim.fn.reg_recording() is not '', so our stopping function
    -- will not throw error
    if visual_repeat_is_recording then
      cl('Stopping due to user pressing q')
      My_visual_repeat_stop()
    end
  end,
})

-- -- For debugging only
-- vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI', 'TextChangedP' }, {
--   desc = 'My visual repeat: invalidate on change from other sources',
--   group = vim.api.nvim_create_augroup('my-visual-repeat-invalidate', { clear = true }),
--   callback = function(arg)
--     cl(arg.event .. ' ' .. vim.api.nvim_buf_get_var(0, 'changedtick'))
--   end,
-- })

return M
