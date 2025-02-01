-- NOTE: which-key maps, then replays keys, causing us to capture 2 times
-- the same keystroke sequences, e.g. vgJ should result in just 2 lines joined, not 3.
-- There seems to be no way to detect inside on_key() whether the keys are from
-- which-key or not.
-- TODO: maybe not even map v,V but use mode changes to start recording?
-- TODO: expose a function is_active -> `not tracking == nothing` to be used in statusline
-- TODO: maybe just diff 20 above/below lines to get inserted text? Problematic when pasting in visual.
-- TODO: edge case ggc<text..> will be repeated as gc<text..> which is bad, since text is not
-- a repeatable sequence, but text. Maybe perform change seq with `mx!` flag,
-- double check we are still in insert, then replay the saved ". register.
local M = {}
local opt = {
  ---We need to be able to tell whether it was e.g. 'c' or 'gc' (or some user mapping) that
  ---triggered change to be able to replay just the change on visual-selection-dot
  -- TODO: search for `v_` in telescope for all possible default shortcuts?
  -- mappings_that_edit_in_visual = { 'm', 'x', 'X', 'd', 'D', 'c', 'p', 'r', 'gc', 's', '>', '<', 'U' },
  -- TODO: support non-same-string sequences, to be able to say: {'a', 'b'} triggers change, but the rest
  -- of mappings beginning with 'a' do not.
  -- TODO: check <Ignore> for further workaround mappings

  -- There seems to be no way to tell wheter a key sequence e.g. "..ggggggg<C-a>" ends with
  -- gg to go to top, then <C-a> or g<C-a> which is add an increasing count (:h v_g_CTRL-A)
  -- on_key() does not inform the attached listener when a mapping counts as complete.
  mappings_that_edit_in_visual = { 's', 'r', 'gc', 'c', '<lt>', '>', '<C-a>', 'g<C-a>' }, -- TODO: check 'r'
  ---This would be likely due to user incorrectly applying workaround with force_alive
  warn_on_keystrokes_recorded = 500,
}

local enable_logging = true -- for debugging

local force_alive = false
local changed_tick_at_start = -1
-- TODO: rename to is_disabled, update checks
local is_active = false
-- must store visual_mode, we cannot rely on vim.fn.visualmode()
-- since there could be a visual block with no change, before our (valid) repeat is called.
local visual_mode_at_start = 'v' ---@type 'v' | 'V'
local keys_recorded = {} ---@type string[]
local insert_was_entered = false
---@type { keys: string[], keys_translated: string[], mode: 'v' | 'V', dot_register_text: string?  }
local last_valid_edit = {
  keys = {}, --- will be used as part of a macro string
  --- keys, mapped with keytrans(), needed to be able to match raw keys when determining the
  --- editing sequence during dot_on_visual_selection
  keys_translated = {},
  mode = 'v',
  ---nil means non-insert-change (like, gc or surround), in this case
  ---we will not need to append <Esc> to macro string before replaying.
  dot_register_text = nil,
}

local log = function(...)
  if not enable_logging then
    return
  end
  vim.cmd.redraw() -- to avoid 'press enter' in :messages
  vim.print(...)
end

function M.setup()
  -- vim.tbl_deep_extend
  -- normalize 'g<C-a>' -> 'g<C-A>' to be consistent, since we will be comparing
  -- with keytrans()'d strings.
  opt.mappings_that_edit_in_visual = vim.tbl_map(function(v)
    return vim.fn.keytrans(vim.api.nvim_replace_termcodes(v, true, true, true))
  end, opt.mappings_that_edit_in_visual)
  -- log(opt.mappings_that_edit_in_visual)
end

M.setup()

---@param must_be_true boolean
---@param message string
local function assert(must_be_true, message)
  if must_be_true ~= true then
    message = message .. 'Better visual repeat: '
    vim.notify(message, vim.log.levels.ERROR)
  end
end

function M.toggle_logging()
  enable_logging = not enable_logging
end

-- is vim macro active
-- cursormovedI autocmd
local function is_vim_macro_active()
  return vim.fn.reg_recording() ~= '' or vim.fn.reg_executing() ~= ''
end

local function reset_state()
  log('Resetting state') -- but not overwriting last valid edit
  force_alive = false
  changed_tick_at_start = -1
  is_active = false
  visual_mode_at_start = 'v'
  keys_recorded = {}
  insert_was_entered = false
end

Better_visual_noop = function() end

-- @param motion: when called the first time by us, will be nil.
-- When called as a repeat (g@l) by nvim, it will be set to 'char' (see :h g@)
-- must be global in order to be able to use operatorfunc
function Better_visual_repeat(motion)
  if motion == nil then
    log('First call')
    changed_tick_at_start = vim.api.nvim_buf_get_var(0, 'changedtick')
    return
  end

  -- this is repeat by .
  local t_begin = os.clock()
  log('Repeat call')
  log(last_valid_edit)

  M.stop('Repeat call')

  -- NOTE: in ". register, when typing <, it is captured as a regular 1-char '<', not as 4-char '<lt>'
  -- string, so no need to additionally escape.
  -- NOTE: dot register needs to be executed with bang!, noremapped aka normal! otherwise
  -- chars like +U will be added, hence the 'n' flag.
  -- The recorded movements including the final edit command should be executed as mapped, non-bang,
  -- to replicate any potential remaps, hence the 'm' flag.

  -- 'n' to avoid triggering our mapping that will start recording again
  vim.api.nvim_feedkeys(last_valid_edit.mode, 'n', false)
  local movement_keys_with_edit = table.concat(last_valid_edit.keys)
  vim.api.nvim_feedkeys(movement_keys_with_edit, 'm', false)

  if last_valid_edit.dot_register_text then
    -- TODO: just save the register as single string with getreg(). Are there cases
    -- dot register may be linewise?
    -- escape_ks = true does not seem to affect arrow movement
    -- adding 'x' flag will make it exit insert, not adding <Esc> for this reason
    vim.api.nvim_feedkeys(last_valid_edit.dot_register_text, 'n', false)
  end

  -- executes typeahead, will exit insert, will ensure our operatorfunc is set after
  -- the regular repeat action is stored by vim, overriding the stored repeat action.
  vim.api.nvim_feedkeys('', 'nx', false)

  log((os.clock() - t_begin) * 1000 .. ' ms') -- ms, measured 0ms - 2ms

  -- needed so that a second (consequtive) . repeats g@l instead of doing regular repeat
  -- TODO: check if needed to wrap with vim.schedule(): record a visual
  -- edit, do a non-visual one, do a dot-on-selection, do a . in normal. If what repeats
  -- is not our function, but the previous (unrecorded non-visual) edit, wrapping may be needed.
  vim.go.operatorfunc = 'v:lua.Better_visual_noop'
  vim.cmd('normal! g@l')
  vim.go.operatorfunc = 'v:lua.Better_visual_repeat'
end

---Can be called from a mapping as a workaround for another plugin.
---Stop all recording.
---@param abort_with_reason string?
---If abort_with_reason is provided, we will abort and discard / invalidate anything that was recorded.
---Otherwise we will follow the usual steps to determine whether the recorded edit is valid.
function M.stop(abort_with_reason)
  if not is_active then
    -- if already inactive, do nothing. May occur if >1 stop() are scheduled.
    log('Already inactive')
    return
  end

  log('Stopping rec')

  local changed_tick_current = vim.api.nvim_buf_get_var(0, 'changedtick')
  if abort_with_reason == nil and changed_tick_current == changed_tick_at_start then
    -- no changes were made
    abort_with_reason = 'No changes detected'
  end

  if abort_with_reason ~= nil then
    log('Aborting: ' .. abort_with_reason)
    reset_state()
    return
  end

  -- at this point the recorded edit is valid and can be repeated.
  -- If an edit was made in insert the text will be in ". register. If 'c' was pressed and
  -- nothing was entered (text was deleted), ". register will be empty string ("")
  log('Updating last valid edit')
  last_valid_edit = {
    keys = keys_recorded,
    keys_translated = vim.tbl_map(function(k)
      return vim.fn.keytrans(k)
    end, keys_recorded),
    mode = visual_mode_at_start,
    dot_register_text = insert_was_entered and vim.fn.getreg('.') or nil,
  }
  log(last_valid_edit)
  reset_state()

  vim.schedule(function()
    -- schedule is needed, otherwise just the last action is repeated, not our g@l
    log('setting last cmd to our g@l')
    -- vim keeps the individual edit as last, force it to be our g@l
    vim.go.operatorfunc = 'v:lua.Better_visual_noop'
    vim.cmd('normal! g@l')
    vim.go.operatorfunc = 'v:lua.Better_visual_repeat'
  end)
end

function M.dot_on_visual_selection()
  if is_vim_macro_active() then
    M.stop('Vim recording detected (dot on visual selection)')
    return
  end

  assert(is_active, 'Dot on visual selection: expected is_active=true')

  if #last_valid_edit.keys == 0 or not is_active then
    M.stop('No keys recorded yet or plugin disabled')
    return
  end

  local mode = vim.fn.mode(1)
  if mode ~= 'v' and mode ~= 'V' then
    log('Not in visual, but in: ' .. mode)
    M.stop('Unexpected mode: ' .. mode)
    return
  end

  -- Discard recording, since we will replay
  M.stop('Will do . on visual selection') -- not defensive, on every visual we always start recording

  log(last_valid_edit)

  -- Determine when the editing sequence begins, then replay only it, skipping the
  -- preceding motions part.

  -- NOTE: we could also use TextChanged autocmd to determine on which keystroke the change
  -- occurs. It would be triggered after ModeChanged, so we would need to schedule-wrap
  -- M.stop() from ModeChanged, to avoid disabling the plugin before this could trigger.
  -- Even then, (from testing) the editing keystroke is always the last one of keys_recorded.

  local smallest_idx_found = nil -- nil for not found
  for _, edit_key in ipairs(opt.mappings_that_edit_in_visual) do
    -- NOTE: #recorded_key can be >1
    local idx_found = nil -- nil for not found
    for i, translated_key in ipairs(last_valid_edit.keys_translated) do
      if translated_key == edit_key then
        idx_found = i
        break
      end
    end
    if smallest_idx_found == nil or (idx_found ~= nil and idx_found < smallest_idx_found) then
      smallest_idx_found = idx_found
    end
  end

  if smallest_idx_found == nil then
    log('No dot_on_visual_selection edit keys in recording')
    return
  end

  local edit_keys_str = table.concat(last_valid_edit.keys, '', smallest_idx_found)

  log('Dot on selection (visual): ' .. edit_keys_str)
  -- for flag explanation see Better_visual_repeat()
  vim.api.nvim_feedkeys(edit_keys_str, 'm', false)
  if last_valid_edit.dot_register_text then
    log('Dot on selection (insert): ' .. last_valid_edit.dot_register_text)
    -- TODO: maybe check if insert is active before replaying insert mode stuff
    -- otherwise unexpected things may happen? may require to 'x' between calls
    vim.api.nvim_feedkeys(last_valid_edit.dot_register_text, 'n', false)
  end
  vim.api.nvim_feedkeys('', 'nx', false)

  vim.go.operatorfunc = 'v:lua.Better_visual_noop'
  vim.cmd('normal! g@l')
  vim.go.operatorfunc = 'v:lua.Better_visual_repeat'
end

-------------------- On key / autocmds -----------------------------------------------

local on_key_logging = false -- for debugging

local ns = vim.api.nvim_create_namespace('BetterVisualRepeat')
vim.on_key(function(mapped, typed)
  -- This callback is triggered before ModeChanged's callback

  if on_key_logging then
    -- TODO: for better logging see what which-key uses to print register content
    -- it shows the "decoded" chars instead of byte-like sequences
    log('--------------------------')
    log('mapped: ' .. mapped .. ' | ' .. vim.fn.keytrans(mapped) .. ' typed: ' .. typed .. ' | ' .. vim.fn.keytrans(typed) .. ' ')
    local mode_dict = vim.api.nvim_get_mode()
    log('mode: ' .. mode_dict.mode .. ' ' .. (mode_dict.blocking and 'block!' or '') .. ' state: ' .. vim.fn.state())
    log('--------------------------')
  end

  if not is_active then
    return
  end
  if insert_was_entered then
    -- stop recording when in insert
    return
  end
  if typed ~= '' then
    table.insert(keys_recorded, typed)
  end
end, ns)

vim.api.nvim_create_autocmd({ 'RecordingEnter' }, {
  desc = "Better visual repeat - disable on vim's recording",
  group = vim.api.nvim_create_augroup('better-visual-recording-disable', { clear = true }),
  callback = function()
    if not is_active then
      return
    end
    M.stop('Vim recording started')
  end,
})

vim.api.nvim_create_autocmd({ 'ModeChanged' }, {
  desc = 'Better visual repeat update',
  group = vim.api.nvim_create_augroup('better-visual-repeat-modes', { clear = true }),
  callback = function()
    -- This callback is triggered after on_key's callback
    -- Determines whether it's time to stop or should we go on.
    if not is_active then
      return
    end

    local old_mode = vim.v.event.old_mode
    local new_mode = vim.v.event.new_mode
    log(old_mode .. ' -> ' .. new_mode .. ' ' .. vim.api.nvim_buf_get_var(0, 'changedtick'))

    if force_alive then
      return
    end

    if new_mode == 'i' then
      insert_was_entered = true
      return
    end

    -- mode 'no' stands for normal operator pending, see :h mode()
    -- having also old_mode == 'no' helps with some plugins that go:
    -- `v -> no -> n -> v -> n` . so far no adverse effects.
    if new_mode == 'v' or new_mode == 'V' or new_mode == 'no' or old_mode == 'no' then
      -- do not cancel recording when switching between regular / line visual, or making changes
      return
    end

    -- we are out of visual now, so stopping recording
    M.stop()
  end,
})

-- vim.api.nvim_create_autocmd({ 'TextChanged' }, {
--   desc = 'Better visual repeat text change',
--   group = vim.api.nvim_create_augroup('better-visual-repeat-text-change', { clear = true }),
--   callback = function()
--     if not is_active then
--       return
--     end
--     log('Text changed2')
--     if keys_len_at_first_change == -1 then
--       log('Updating keys_len_at_first_change')
--       keys_len_at_first_change = #keys_recorded
--     end
--   end,
-- })

------------------- Mapping functions ---------------------------------------------

function M.better_v()
  vim.cmd('normal! v')
  if is_vim_macro_active() then
    log('Regular recording / replaying ongoing.')
    return
  end
  reset_state()
  log('start v ' .. vim.api.nvim_buf_get_var(0, 'changedtick'))
  is_active = true
  visual_mode_at_start = 'v'
  Better_visual_repeat()
end

function M.better_V()
  vim.cmd('normal! V')
  if is_vim_macro_active() then
    log('Regular recording / replaying ongoing.')
    return
  end
  reset_state()
  log('start V ' .. vim.api.nvim_buf_get_var(0, 'changedtick'))
  is_active = true
  visual_mode_at_start = 'V'
  Better_visual_repeat()
end

------------------- Test mappings ---------------------------------------------

vim.keymap.set('n', '<C-m>', function()
  on_key_logging = not on_key_logging
end, { desc = 'Better visual repeat debug: Toggle on_key() logging' })

vim.keymap.set('n', 'v', M.better_v, { desc = 'Better v' })
vim.keymap.set('n', '<C-v>', M.better_V, { desc = 'Better V' })
vim.keymap.set('v', '.', M.dot_on_visual_selection, { desc = 'Better . on visual selection' })

return M
