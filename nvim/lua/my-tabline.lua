local normalize_filename = require('my-helpers').normalize_filename
local find_key_pred = require('my-helpers').find_key_pred
local find_key = require('my-helpers').find_key
local concat = require('my-helpers').safe_concat
local remap = require('my-helpers').remap
-- local log_my_error = require('my-helpers').log_my_error

vim.opt.showtabline = 2

-- will also be set when restoring order from session
-- not using string[] with file paths, since there can be multiple
-- valid buffers with path = ''
---@type integer[]
local bufnr_order = {}

-- using this to prevent tabline twitching when switching between unlisted
-- (e.g. help) buffer and normal buffer
-- TODO: update this before entering another buffer
---@type integer
local last_active_listed_buf = nil

local function is_listed(bufnr)
  -- buftype 'quickfix' is listed, we filter out any non-normal buffers
  return vim.bo[bufnr].buflisted and vim.bo[bufnr].buftype == ''
end

local function draw_buf_obj(buf_obj)
  local cur_buf = vim.api.nvim_get_current_buf()
  local str = ''
  local hi = ''
  if buf_obj.bufnr == cur_buf then
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
  str = concat(str, hi, '   ', buf_obj.displayed_name, buf_obj.modified and ' •▕' or '  ▕')
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
  -- left buffer.
  while (not nothing_else_fits) and available_width > 0 and (left_el ~= nil or right_el ~= nil) do
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
  local not_ordered_buf_objs = {}

  -- copy buf objs whose bufnrs are in My_buf_order into `ordered` list
  for _, bufnr in pairs(bufnr_order) do
    local index = find_key_pred(all_buf_objs, function(b)
      return b.bufnr == bufnr
    end)
    if index then
      table.insert(ordered_buf_objs, all_buf_objs[index])
    end
  end

  -- copy the rest into ordered list
  for _, b in pairs(all_buf_objs) do
    local index = find_key_pred(bufnr_order, function(bufnr)
      return b.bufnr == bufnr
    end)
    if not index then
      table.insert(not_ordered_buf_objs, b)
    end
  end

  -- append not_ordered_buf_objs on ordered_buf_objs (by mutating it)
  vim.list_extend(ordered_buf_objs, not_ordered_buf_objs)

  -- update My_buf_order
  bufnr_order = vim.tbl_map(function(b)
    return b.bufnr
  end, ordered_buf_objs)

  -- log_my_error('My_buf_order3')
  -- log_my_error(My_buf_order)

  render_tabline(ordered_buf_objs)
end

vim.api.nvim_create_autocmd({
  -- 'BufAdd', -- covered by BufEnter
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
  'UIEnter',
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
  vim.print(cur_index)
  vim.print(bufnr_order)

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
  vim.print(bufnr_order)

  update_tabline()
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

-- TODO: for jump with labels, use "temporary" remapping of <esc> local to window (buffer?), then unmap it
-- on entering another buffer, auto quit jump mode
