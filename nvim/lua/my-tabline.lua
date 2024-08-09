local normalize_filename = require('my-helpers').normalize_filename
local find_key_pred = require('my-helpers').find_key_pred
local find_key = require('my-helpers').find_key
local concat = require('my-helpers').safe_concat
local remap = require('my-helpers').remap
local log_my_error = require('my-helpers').log_my_error

vim.opt.showtabline = 2

local M = {}

-- will also be set when restoring order from session
-- not using string[] with file paths, since there can be multiple
-- valid buffers with path = ''
---@type integer[]
local bufnr_order = {}

-- using this to prevent tabline twitching when switching between unlisted
-- (e.g. help) buffer and normal buffer
-- TODO: update this before entering another buffer
---@type integer | nil
local last_active_listed_buf = nil

-- each letter's position corresponds to buffer position in bufnr_order
local jump_labels = 'FDSJKLGHALVCMBNZREUIWOTYQP'
local jumping = false

-- local called = 0 -- for benchmarks

local function is_listed(bufnr)
  -- buftype 'quickfix' is listed, we filter out any non-normal buffers
  return vim.bo[bufnr].buflisted and vim.bo[bufnr].buftype == ''
end

local function draw_buf_obj(buf_obj)
  local cur_buf = vim.api.nvim_get_current_buf()
  local is_cur = buf_obj.bufnr == cur_buf
  local hi = ''
  if is_cur then
    if buf_obj.modified then
      hi = '%#MyTablineCurrentMod#'
    else
      hi = '%#MyTablineCurrent#'
    end
  else
    if buf_obj.modified then
      hi = '%#MyTablineHiddenMod#'
    else
      hi = '%#MyTablineHidden#'
    end
  end
  local jump_label = jumping and not is_cur and buf_obj.jump_label or ' '
  local str = concat(hi, ' ', jump_label, ' ', buf_obj.displayed_name)
  str = concat(str, buf_obj.modified and ' •▕' or '  ▕')
  return str, #buf_obj.displayed_name + 6 -- 3 leading spaces, 3 following chars as above
end

local function render_tabline(objs)
  -- vim.print('objs')
  -- vim.print(objs)
  -- vim.print(My_buf_order)
  local win_columns = vim.api.nvim_get_option_value('columns', { scope = 'global' })
  -- 3 spaces for 'T' annotation if there is a second tab,
  -- ' <▕' for left indicator, ' > ' for right indicator: 3 spaces both
  -- Total: 9 additional spaces reserved
  local available_width = win_columns - 9

  local center_index = find_key_pred(objs, function(obj)
    return obj.bufnr == vim.api.nvim_get_current_buf()
  end)

  -- vim.print('center_index')
  -- vim.print(center_index)

  -- when we have switched to an unlisted buffer, the last active buffer
  -- may have been deleted, e.g. by a plugin (unlikely, but still)
  center_index = center_index or find_key_pred(objs, function(obj)
    return obj.bufnr == last_active_listed_buf
  end)

  if not center_index and #objs > 0 then
    center_index = 1
  elseif #objs < 1 then
    vim.o.tabline = 'My tabline: no buffer found!'
    return
  end

  local res, center_width = draw_buf_obj(objs[center_index])
  available_width = available_width - center_width

  local left_index = center_index - 1
  local right_index = center_index + 1
  local left_el = objs[left_index]
  local right_el = objs[right_index]
  local nothing_else_fits = false

  -- Start with the center buf, the add left / right buffer, one at a time,
  -- alternating between left / right, until full. Always try to fit the whole
  -- left buffer first.
  -- NOTE: not using (available_width > 0) in while-condition, due to edge case:
  -- if we just managed to fit an element and the new available_width is exactly 0,
  -- then another iteration is needed, in order to just add the <> icons, in case
  -- there are more items. Using (available_width > 0) would prevent it.
  while (not nothing_else_fits) and (left_el ~= nil or right_el ~= nil) do
    -- calculating here potential indicators, even if not used in all the below cases
    local left_icon = '%#TabLineFill# <▕'
    local right_icon = '%#TabLineFill# > '
    local maybe_left_icon = left_index > 1 and left_icon or ''
    local maybe_right_icon = right_index < #objs and right_icon or ''
    if left_el ~= nil and right_el ~= nil then
      -- both left and right want to be added
      local left_str, left_width = draw_buf_obj(left_el)
      local right_str, right_width = draw_buf_obj(right_el)
      if available_width >= left_width + right_width then
        -- both fit
        res = concat(left_str, res, right_str)
        available_width = available_width - (left_width + right_width)
      else
        -- cannot fit both, no more iterations
        nothing_else_fits = true
        -- can at least one fit fully?
        if available_width >= left_width then
          -- left can fit, but not right
          res = concat(maybe_left_icon, left_str, res, right_icon)
        elseif available_width >= right_width then
          -- right can fit, but not left
          res = concat(left_icon, res, right_str, maybe_right_icon)
        else
          -- neither can fit
          res = concat(left_icon, res, right_icon)
        end
      end
    elseif left_el ~= nil then
      -- only left buffer wants to be added
      local left_str, left_width = draw_buf_obj(left_el)
      if available_width >= left_width then
        -- it fits
        res = concat(left_str, res)
        available_width = available_width - left_width
      else
        -- it does not fit
        nothing_else_fits = true
        res = concat(left_icon, res)
      end
    elseif right_el ~= nil then
      -- only right buffer wants to be added
      local right_str, right_width = draw_buf_obj(right_el)
      if available_width >= right_width then
        -- it fits
        res = concat(res, right_str)
        available_width = available_width - right_width
      else
        -- it does not fit
        nothing_else_fits = true
        res = concat(res, right_icon)
      end
    end

    left_index = left_index - 1
    right_index = right_index + 1
    left_el = objs[left_index]
    right_el = objs[right_index]
  end

  -- separator
  res = concat(res, '%#TabLineFill#%=')
  res = concat(res, #vim.api.nvim_list_tabpages() > 1 and '%#MyStatusLineLspError# T ' or '')

  -- called = called + 1 -- for benchmarks
  -- res = concat(res, called)

  vim.o.tabline = res
end

local function map_current_bufs()
  local all_buf_nrs = vim.api.nvim_list_bufs()
  local listed_bufs = vim.tbl_filter(function(bufnr)
    return is_listed(bufnr)
  end, all_buf_nrs)

  -- if #My_buf_order == 0 then
  --   -- should be set only when initializing, listed bufs should never be empty
  --   My_buf_order = listed_bufs
  -- end

  return vim.tbl_map(function(b)
    local buf_obj = {
      bufnr = b,
      normalized_path = '',
      displayed_name = '',
      modified = false,
      jump_label = '-', -- only shown when having >26 buffers and jumping to one of the last
    }
    buf_obj.normalized_path = normalize_filename(vim.api.nvim_buf_get_name(b))
    buf_obj.displayed_name = vim.fn.fnamemodify(buf_obj.normalized_path, ':t')
    if buf_obj.displayed_name == '' then
      buf_obj.displayed_name = '[No name]'
    end
    buf_obj.modified = vim.bo[b].modified
    return buf_obj
  end, listed_bufs)
end

local function update_tabline()
  -- determine last_active_listed_buf, update order
  local cur_bufnr = vim.api.nvim_get_current_buf()

  local cur_is_listed = is_listed(cur_bufnr)
  -- log_my_error('cur_bufnr ' .. cur_bufnr)
  -- log_my_error('My_buf_order1')
  -- log_my_error(My_buf_order)
  -- log_my_error('cur_is_listed ' .. (cur_is_listed and 'yes' or 'no'))
  --

  if cur_is_listed then
    local existing_index = find_key(bufnr_order, cur_bufnr)
    -- log_my_error({ 'index in our order ', existing_index })
    if not existing_index then
      -- new buffer, we determine its position in My_buf_order
      local last_active_listed_pos = find_key(bufnr_order, last_active_listed_buf)
      if last_active_listed_pos then
        -- add to the right (shifts up existing elements to make space,
        -- ok if its the last element in the list too, the list remains contiguous)
        table.insert(bufnr_order, last_active_listed_pos + 1, cur_bufnr)
      else
        -- just append
        -- NOTE: if there are restored buffers from session, but not our
        -- buffer order, then current tab will be the leftmost item in tabline.
        -- The following tabs will be the same order as in :ls.
        -- If for some reason we want the :ls order, call the following insert()
        -- only when #My_buf_order > 0
        table.insert(bufnr_order, cur_bufnr)
      end
    end
    -- finally update last active
    -- log_my_error('setting last active to: ' .. cur_bufnr)
    last_active_listed_buf = cur_bufnr
  end

  -- log_my_error('My_buf_order2')
  -- log_my_error(My_buf_order)

  --------------------------

  -- determine order
  local all_buf_objs = map_current_bufs()
  local ordered_buf_objs = {}

  -- copy buf objs whose bufnrs are in My_buf_order into `ordered` list
  for _, bufnr in pairs(bufnr_order) do
    local index = find_key_pred(all_buf_objs, function(b)
      return b.bufnr == bufnr
    end)
    if index then
      table.insert(ordered_buf_objs, all_buf_objs[index])
    end
  end

  -- second pass, append the rest
  for _, b in pairs(all_buf_objs) do
    local index = find_key_pred(bufnr_order, function(bufnr)
      return b.bufnr == bufnr
    end)
    if not index then
      table.insert(ordered_buf_objs, b)
    end
  end

  -- assign jump labels
  for i, bufobj in pairs(ordered_buf_objs) do
    local jump_label = jump_labels:sub(i, i)
    if jump_label then
      bufobj.jump_label = jump_label
    end
  end

  -- update My_buf_order
  bufnr_order = vim.tbl_map(function(b)
    return b.bufnr
  end, ordered_buf_objs)

  -- log_my_error('My_buf_order3')
  -- log_my_error(My_buf_order)

  render_tabline(ordered_buf_objs)
end

vim.api.nvim_create_autocmd({
  'BufAdd', -- in case a plugin opens a non-active, but listed buffer
  -- 'BufDelete', -- triggers before
  'BufEnter', -- already have a separate autocmd for this one
  'BufFilePost',
  -- 'BufLeave', -- triggers before
  'BufModifiedSet',
  'BufNew',
  -- 'BufNewFile', -- docs dont say whether it triggers before, anyway should be covered by BufNew
  -- 'BufReadPost', -- covered by BufEneter
  -- 'BufWipeout', -- triggers before
  'DirChanged',
  'TabClosed',
  'TabEnter',
  -- 'TabNew', -- docs dont say whether it triggers before, anyway should be covered by TabEnter
  -- 'UIEnter', -- will update during restore_order_from_session(), which always runs on UIEnter
  'VimResized',
  'WinEnter',
}, {
  desc = 'My tabline: manually update',
  group = vim.api.nvim_create_augroup('my-update-tabline', {}),
  -- NOTE: wrapping here is necessary, otherwise nvim_get_current_buf() does not give
  -- use the actual current bufnr that we have switching to, but the previous bufnr.
  -- We need this to correctly set the last active listed bufnr.
  -- The wrapping is the simplest solution, we could also move the code for setting
  -- last active listed buffer to a separate function, then call it on BufEnter
  -- and remove the wrap. It's not worth the effort, also its better to have a single
  -- function called on every autocmd, to ensure the same logic is followed.
  callback = vim.schedule_wrap(update_tabline),
})

---Direction should be 'left' or 'right'
local function switch_to_buffer(direction)
  local cur_index = find_key(bufnr_order, vim.api.nvim_get_current_buf())
  cur_index = cur_index or find_key(bufnr_order, last_active_listed_buf)
  cur_index = cur_index or 1

  local target_bufnr = nil
  if direction == 'left' then
    if cur_index == 1 then
      -- go to the rightmost
      target_bufnr = bufnr_order[#bufnr_order]
    else
      target_bufnr = bufnr_order[cur_index - 1]
    end
  else
    -- direction is right
    if cur_index == #bufnr_order then
      target_bufnr = bufnr_order[1]
    else
      target_bufnr = bufnr_order[cur_index + 1]
    end
  end

  if not target_bufnr then
    local msg = 'My tabline: could not determine current buffer place in buffers order'
    vim.notify(msg, vim.log.levels.ERROR)
    return
  end

  vim.api.nvim_set_current_buf(target_bufnr)
end

---Direction should be 'left' or 'right'
local function move_buffer(direction)
  local cur_index = find_key(bufnr_order, vim.api.nvim_get_current_buf())
  if not cur_index or #bufnr_order == 1 then
    return
  end

  if direction == 'left' then
    local removed_bufnr = table.remove(bufnr_order, cur_index)
    if cur_index == 1 then
      table.insert(bufnr_order, removed_bufnr)
    else
      table.insert(bufnr_order, cur_index - 1, removed_bufnr)
    end
  else
    -- direction is right
    -- do not remove beforehand, it will change list length
    if cur_index == #bufnr_order then
      local removed_bufnr = table.remove(bufnr_order, cur_index)
      table.insert(bufnr_order, 1, removed_bufnr)
    else
      local removed_bufnr = table.remove(bufnr_order, cur_index)
      table.insert(bufnr_order, cur_index + 1, removed_bufnr)
    end
  end

  update_tabline()
end

local function jump()
  vim.print('jump to buffer label: ')
  jumping = true
  update_tabline()
  vim.cmd.redrawtabline() -- needed, otherwise tabline is not updated
  -- from testing getcharstr() returns string, even for mouse clicks
  local char = vim.fn.getcharstr():upper()
  jumping = false
  vim.print('') -- clear
  update_tabline()
  local char_index = jump_labels:find(char, 1, true)
  local target_bufnr = bufnr_order[char_index]
  if target_bufnr then
    vim.api.nvim_set_current_buf(bufnr_order[char_index])
  end
end

remap('n', '(', function()
  switch_to_buffer('left')
end, { desc = 'Go to previous buffer' })
remap('n', ')', function()
  switch_to_buffer('right')
end, { desc = 'Go to next buffer' })

remap('n', '{', function()
  move_buffer('left')
end, { desc = 'Go to previous buffer' })
remap('n', '}', function()
  move_buffer('right')
end, { desc = 'Go to next buffer' })

remap('n', '<Leader>b', jump, { desc = 'Jump to a buffer label' })

function M.save_order_to_session()
  local file_paths = vim.tbl_map(function(bufnr)
    return normalize_filename(vim.api.nvim_buf_get_name(bufnr))
  end, bufnr_order)

  local file_paths_json = vim.json.encode(file_paths)

  if string.find(file_paths_json, "'") then
    -- we will be appending a line like: let g:my_buf_order = '["path1", "path2"]'
    log_my_error("My: Found filename containing quote ('). Not saving buffer order.")
    return
  end

  local session_file = vim.v.this_session
  if vim.fn.filewritable(session_file) ~= 1 then
    log_my_error('My: No session file found. Not saving buffer order.')
    return
  end

  vim.fn.writefile({ '', "let g:my_buf_order = '" .. file_paths_json .. "'" }, session_file, 'as')
end

-- NOTE: always call update_tabline() before returning, to be consistent
-- this func should only be called on UIEnter, in my-mini-sessions.lua
function M.restore_order_from_session()
  local json = vim.g.my_buf_order
  if not json then
    vim.notify('My: my_buf_order global not found. Not restoring buffer order.', vim.log.levels.WARN)
    update_tabline()
    return
  end
  local decode_ok, file_paths_order = pcall(vim.json.decode, json)
  if not decode_ok then
    local msg = 'My: my_buf_order global was found, but could not be decoded. Not restoring buffer order.'
    vim.notify(msg, vim.log.levels.WARN)
    update_tabline()
    return
  end

  local new_bufnr_order = {}
  local all_buf_objs = map_current_bufs()
  -- append filepaths' corresponding bufnrs (if exist)
  for _, file_path in pairs(file_paths_order) do
    local index = find_key_pred(all_buf_objs, function(bufobj)
      return bufobj.normalized_path == file_path
    end)
    if index then
      table.insert(new_bufnr_order, all_buf_objs[index].bufnr)
    end
  end
  -- the rest will be appended by our update_tabline func
  bufnr_order = new_bufnr_order
  update_tabline()
  vim.print('My: buffer order restored correctly')
end

-- -- calls:
-- -- 85 when starting
-- -- 2 when switching to another window
-- -- 3 for :enew
-- -- 11 when opening telescope with <leader-s>h
--
-- -- benchmarks:
-- -- with 32 listed buffers
-- --0.4ms per draw --> there is room for improvement
-- vim.keymap.set('n', '<C-F11>', function()
--   local t_beg = os.clock()
--   local iterations = 10000 -- 10k better
--   -- local iterations = 100000
--   for _ = 1, iterations do
--     update_tabline()
--   end
--   local t_end = os.clock()
--   vim.print('Draw tabline (ms): ' .. (t_end - t_beg) / iterations * 1000) -- ms
-- end)
--
-- -- 0.0032ms per draw
-- vim.keymap.set('n', '<C-F9>', function()
--   local t_beg = os.clock()
--   local iterations = 100000
--   for _ = 1, iterations do
--     vim.o.tabline = 'test123'
--   end
--   local t_end = os.clock()
--   vim.print('Dummy string (ms) :', (t_end - t_beg) / iterations * 1000) -- ms
-- end)

return M
