local remap = require('my-helpers').remap

local cl = require('my-helpers').create_cond_logger('myvisualrep')
_G.myvisualrep = false -- help autocomplete when manually overriding to true

local visual_repeat_is_recording = false --- to differentiate from regular macro recording
local changed_tick_start = 0
-- must store visual_mode, we cannot rely on vim.fn.visualmode()
-- since there could be a visual block with no change, before our (valid) repeat is called.
local visual_mode = 'v'
local last_valid_macro = ''
local MY_MACRO_REGISTER = 'v'

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

remap({ 'n', 'v' }, 'V', '<C-v>', { desc = 'V is the new visual block' })
remap('v', '<C-v>', 'V', { desc = '<C-v> is the new linewise visual' })
-- NOTE: there is no sense in recording gv, since reselection does not
-- store the original selection movements. This makes it impossible to
-- replay the actions following gv on the next lines.

vim.api.nvim_create_autocmd({ 'ModeChanged' }, {
  desc = 'My: visual repeat update',
  group = vim.api.nvim_create_augroup('my-visual-repeat-modes', { clear = true }),
  callback = function()
    local old_mode = vim.v.event.old_mode
    local new_mode = vim.v.event.new_mode
    cl(old_mode .. ' ' .. new_mode .. ' ' .. vim.api.nvim_buf_get_var(0, 'changedtick'))

    if not visual_repeat_is_recording then
      return
    end
    -- cl('op: ' .. vim.v.operator)
    -- mode 'no' stands for normal operator pending, see :h mode()
    if new_mode == 'v' or new_mode == 'V' or new_mode == 'i' or new_mode == 'no' or old_mode == 'no' then
      -- do not cancel recording when switching between regular / line visual, or making changes
      return
    end

    -- we are out of visual now, so stopping recording

    if vim.fn.reg_recording() == '' then
      vim.notify('My visual repeat: expected that a macro is being recorded', vim.log.levels.ERROR)
    end

    visual_repeat_is_recording = false
    cl('Stopping rec')
    vim.cmd('normal! q')

    local changed_tick_current = vim.api.nvim_buf_get_var(0, 'changedtick')
    if changed_tick_current == changed_tick_start then
      -- no changes were made
      cl('invalidated by ModeChanged')
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
