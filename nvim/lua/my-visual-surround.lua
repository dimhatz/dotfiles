local L = false
local M = {}
local log = vim.print

function M.visual_surround()
  local mode = vim.fn.mode(1)
  -- vim.print('mode: ' .. mode)
  if mode ~= 'v' and mode ~= 'V' then
    return
  end
  local is_visual_line_mode = mode == 'V'
  local cursor_pos = vim.fn.getpos('.') ---@type [integer, integer] -- 1-based
  cursor_pos = { cursor_pos[2], cursor_pos[3] }
  local other_side_pos = vim.fn.getpos('v') ---@type [integer, integer]
  other_side_pos = { other_side_pos[2], other_side_pos[3] }
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

  _ = L and log('Better visual surround: targets before adjusting for beyond eol: ', { start_pos, end_pos })
  -- NOTE: actual text insertion happens right _before_ the target column.
  local start_row_text = vim.fn.getline(start_pos[1])
  local end_row_text = vim.fn.getline(end_pos[1])
  if is_visual_line_mode then
    -- start_pos[2] = 1
    start_pos[2] = start_row_text:find('%S') or 1
    end_pos[2] = (end_row_text:find('%S%s*$') or #end_row_text) + 1
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
  _ = L and log('Better visual surround: targets after: ', { start_pos, end_pos })

  local pairs = { '()', '{}', '[]', '<>' }
  local char = vim.fn.getcharstr()
  if char:find('^[%w%p%s]$') == nil then
    -- not checking #char ~= 1 since a multibyte char may be entered
    return
  end
  local pair_to_insert = { char, char } ---@type [string, string]
  for _, pair_str in ipairs(pairs) do
    local idx = pair_str:find(char, 1, true)
    if not idx then
      goto continue
    end
    if idx == 1 then
      pair_to_insert = { pair_str:sub(1, 1) .. ' ', ' ' .. pair_str:sub(2, 2) }
      break
    else
      pair_to_insert = { pair_str:sub(1, 1), pair_str:sub(2, 2) }
      break
    end
    ::continue::
  end

  local targets = { start_pos, end_pos } -- just to match with pairs
  for i = #targets, 1, -1 do
    -- reverse loop, since forward loop would shift text, altering positions
    local target = targets[i]
    -- 0-based
    local insert_row = target[1] - 1
    local insert_col = target[2] - 1
    _ = L and log('Better visual surround: setting text to 0-based: ' .. insert_row .. ' ' .. insert_col)
    vim.api.nvim_buf_set_text(0, insert_row, insert_col, insert_row, insert_col, { pair_to_insert[i] })
  end

  -- nx needed, otherwise gv will not select the desired region
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'nx', false)

  -- make gv select around the added symbol, so that another s + symbol can follow.
  -- When on the same line, 2 or 4 chars have been added to the line, otherwise 1 or 2
  local col_offset = targets[1][1] == targets[2][1] and (2 * #pair_to_insert[1] - 1) or #pair_to_insert[1] - 1
  vim.fn.setpos("'<", { 0, targets[1][1], targets[1][2], 0 })
  vim.fn.setpos("'>", { 0, targets[2][1], targets[2][2] + col_offset, 0 })

  -- also place cursor where the selection started, offsetting for newly inserted chars.
  -- This is consistent with mini-surround' behavior.
  vim.fn.setpos('.', { 0, targets[1][1], targets[1][2] + #pair_to_insert[1], 0 })
end

return M

-- -------------------------- tests from better-visual repeat -----------------------------
-- T['surrounds with non-pair char in v mode and repeats it from normal'] = function()
--   setup({ mappings_that_edit_in_visual = { 's' } })
--   fill_with_text()
--   feed('vesm')
--   lines_eq({ 'maaam bbb ccc', 'dddd eeee ffff', 'xxxxx yyyyy zzzzz' })
--   cur_eq({ 1, 2 })
--   feed('j0.')
--   lines_eq({ 'maaam bbb ccc', 'mddddm eeee ffff', 'xxxxx yyyyy zzzzz' })
--   cur_eq({ 2, 2 })
-- end
--
-- T['surrounds with non-pair char on single-char selection'] = function()
--   setup({ mappings_that_edit_in_visual = { 's' } })
--   fill_with_text()
--   feed('vsm')
--   lines_eq({ 'mamaa bbb ccc', 'dddd eeee ffff', 'xxxxx yyyyy zzzzz' })
--   cur_eq({ 1, 2 })
--   feed('j0.')
--   lines_eq({ 'mamaa bbb ccc', 'mdmddd eeee ffff', 'xxxxx yyyyy zzzzz' })
--   cur_eq({ 2, 2 })
--   feed('j0v.')
--   lines_eq({ 'mamaa bbb ccc', 'mdmddd eeee ffff', 'mxmxxxx yyyyy zzzzz' })
--   cur_eq({ 3, 2 })
-- end
--
-- T['surrounds with non-pair char in v mode and repeats it on selection'] = function()
--   setup({ mappings_that_edit_in_visual = { 's' } })
--   fill_with_text()
--   feed('vesm')
--   lines_eq({ 'maaam bbb ccc', 'dddd eeee ffff', 'xxxxx yyyyy zzzzz' })
--   cur_eq({ 1, 2 })
--   feed('j0vee.')
--   lines_eq({ 'maaam bbb ccc', 'mdddd eeeem ffff', 'xxxxx yyyyy zzzzz' })
--   cur_eq({ 2, 2 })
-- end
--
-- T['surrounds with non-pair char in V mode and repeats it from normal'] = function()
--   setup({ mappings_that_edit_in_visual = { 's' } })
--   fill_with_text()
--   feed('Vsm')
--   lines_eq({ 'maaa bbb cccm', 'dddd eeee ffff', 'xxxxx yyyyy zzzzz' })
--   cur_eq({ 1, 2 })
--   feed('j0.')
--   lines_eq({ 'maaa bbb cccm', 'mdddd eeee ffffm', 'xxxxx yyyyy zzzzz' })
--   cur_eq({ 2, 2 })
-- end
--
-- T['surrounds with non-pair char in V mode, adjusting for leading and trailing whitespace'] = function()
--   setup({ mappings_that_edit_in_visual = { 's' } })
--   fill_with_text({ '  aaa bbb ccc  ', ' dddd eeee ffff ', '\txxxxx yyyyy zzzzz\t' })
--   feed('Vsm')
--   lines_eq({ '  maaa bbb cccm  ', ' dddd eeee ffff ', '\txxxxx yyyyy zzzzz\t' })
--   cur_eq({ 1, 4 })
--   feed('j0.')
--   lines_eq({ '  maaa bbb cccm  ', ' mdddd eeee ffffm ', '\txxxxx yyyyy zzzzz\t' })
--   cur_eq({ 2, 3 })
--   feed('j0.')
--   lines_eq({ '  maaa bbb cccm  ', ' mdddd eeee ffffm ', '\tmxxxxx yyyyy zzzzzm\t' })
--   cur_eq({ 3, 3 })
-- end
--
-- T['surrounds with non-pair char in V mode and repeats it from v-selection'] = function()
--   setup({ mappings_that_edit_in_visual = { 's' } })
--   fill_with_text()
--   feed('Vsm')
--   lines_eq({ 'maaa bbb cccm', 'dddd eeee ffff', 'xxxxx yyyyy zzzzz' })
--   cur_eq({ 1, 2 })
--   feed('j0vee.')
--   lines_eq({ 'maaa bbb cccm', 'mdddd eeeem ffff', 'xxxxx yyyyy zzzzz' })
--   cur_eq({ 2, 2 })
-- end
--
-- T['surrounds with non-pair char in V mode and repeats it from V-selection'] = function()
--   setup({ mappings_that_edit_in_visual = { 's' } })
--   fill_with_text()
--   feed('Vesm') -- the extra e move should not alter the result
--   lines_eq({ 'maaa bbb cccm', 'dddd eeee ffff', 'xxxxx yyyyy zzzzz' })
--   cur_eq({ 1, 2 })
--   feed('j0Vj.')
--   lines_eq({ 'maaa bbb cccm', 'mdddd eeee ffff', 'xxxxx yyyyy zzzzzm' })
--   cur_eq({ 2, 2 })
-- end
--
-- T['surrounds with pair char ) in v mode and repeats it from normal'] = function()
--   setup({ mappings_that_edit_in_visual = { 's' } })
--   fill_with_text()
--   feed('vees)')
--   lines_eq({ '(aaa bbb) ccc', 'dddd eeee ffff', 'xxxxx yyyyy zzzzz' })
--   cur_eq({ 1, 2 })
--   feed('j0.')
--   lines_eq({ '(aaa bbb) ccc', '(dddd eeee) ffff', 'xxxxx yyyyy zzzzz' })
--   cur_eq({ 2, 2 })
-- end
--
-- T['surrounds with pair char ) in v mode and repeats it on selection'] = function()
--   setup({ mappings_that_edit_in_visual = { 's' } })
--   fill_with_text()
--   feed('ves)')
--   lines_eq({ '(aaa) bbb ccc', 'dddd eeee ffff', 'xxxxx yyyyy zzzzz' })
--   cur_eq({ 1, 2 })
--   feed('j0vee.')
--   lines_eq({ '(aaa) bbb ccc', '(dddd eeee) ffff', 'xxxxx yyyyy zzzzz' })
--   cur_eq({ 2, 2 })
-- end
--
-- T['surrounds with pair char ( in v mode and repeats it from normal'] = function()
--   setup({ mappings_that_edit_in_visual = { 's' } })
--   fill_with_text()
--   feed('ves(')
--   lines_eq({ '( aaa ) bbb ccc', 'dddd eeee ffff', 'xxxxx yyyyy zzzzz' })
--   cur_eq({ 1, 3 })
--   feed('j0.')
--   lines_eq({ '( aaa ) bbb ccc', '( dddd ) eeee ffff', 'xxxxx yyyyy zzzzz' })
--   cur_eq({ 2, 3 })
-- end
--
-- T['surrounds with pair char ( in v mode and repeats it on selection'] = function()
--   setup({ mappings_that_edit_in_visual = { 's' } })
--   fill_with_text()
--   feed('ves(')
--   lines_eq({ '( aaa ) bbb ccc', 'dddd eeee ffff', 'xxxxx yyyyy zzzzz' })
--   cur_eq({ 1, 3 })
--   feed('j0vee.')
--   lines_eq({ '( aaa ) bbb ccc', '( dddd eeee ) ffff', 'xxxxx yyyyy zzzzz' })
--   cur_eq({ 2, 3 })
-- end
--
-- T['surrounds with pair char ) in V mode and repeats it from normal'] = function()
--   setup({ mappings_that_edit_in_visual = { 's' } })
--   fill_with_text()
--   feed('Vs)')
--   lines_eq({ '(aaa bbb ccc)', 'dddd eeee ffff', 'xxxxx yyyyy zzzzz' })
--   cur_eq({ 1, 2 })
--   feed('j0.')
--   lines_eq({ '(aaa bbb ccc)', '(dddd eeee ffff)', 'xxxxx yyyyy zzzzz' })
--   cur_eq({ 2, 2 })
-- end
--
-- T['surrounds with pair char ) in V mode and repeats it on selection'] = function()
--   setup({ mappings_that_edit_in_visual = { 's' } })
--   fill_with_text()
--   feed('Vs)')
--   lines_eq({ '(aaa bbb ccc)', 'dddd eeee ffff', 'xxxxx yyyyy zzzzz' })
--   cur_eq({ 1, 2 })
--   feed('j0Vj.')
--   lines_eq({ '(aaa bbb ccc)', '(dddd eeee ffff', 'xxxxx yyyyy zzzzz)' })
--   cur_eq({ 2, 2 })
-- end
--
-- T['surrounds with pair char ( in V mode and repeats it from normal'] = function()
--   setup({ mappings_that_edit_in_visual = { 's' } })
--   fill_with_text()
--   feed('Vs(')
--   lines_eq({ '( aaa bbb ccc )', 'dddd eeee ffff', 'xxxxx yyyyy zzzzz' })
--   cur_eq({ 1, 3 })
--   feed('j0.')
--   lines_eq({ '( aaa bbb ccc )', '( dddd eeee ffff )', 'xxxxx yyyyy zzzzz' })
--   cur_eq({ 2, 3 })
-- end
--
-- T['surrounds with pair char ( in V mode and repeats it on selection'] = function()
--   setup({ mappings_that_edit_in_visual = { 's' } })
--   fill_with_text()
--   feed('Vs(')
--   lines_eq({ '( aaa bbb ccc )', 'dddd eeee ffff', 'xxxxx yyyyy zzzzz' })
--   cur_eq({ 1, 3 })
--   feed('j0Vj.')
--   lines_eq({ '( aaa bbb ccc )', '( dddd eeee ffff', 'xxxxx yyyyy zzzzz )' })
--   cur_eq({ 2, 3 })
-- end
--
-- T['surrounds with pair char ) in v mode on empty lines'] = function()
--   setup({ mappings_that_edit_in_visual = { 's' } })
--   fill_with_text({ '', '', '', '' })
--   feed('vs)')
--   lines_eq({ '()', '', '', '' })
--   cur_eq({ 1, 2 })
--   feed('j0.')
--   lines_eq({ '()', '()', '', '' })
--   cur_eq({ 2, 2 })
--   feed('j0vj.')
--   lines_eq({ '()', '()', '(', ')' })
--   cur_eq({ 3, 1 })
-- end
--
-- T['surrounds with pair char ) in V mode on empty lines'] = function()
--   setup({ mappings_that_edit_in_visual = { 's' } })
--   fill_with_text({ '', '', '', '' })
--   feed('Vs)')
--   lines_eq({ '()', '', '', '' })
--   cur_eq({ 1, 2 })
--   feed('j0.')
--   lines_eq({ '()', '()', '', '' })
--   cur_eq({ 2, 2 })
--   feed('j0Vj.')
--   lines_eq({ '()', '()', '(', ')' })
--   cur_eq({ 3, 1 })
-- end
--
-- T['surrounds with pair char ( in v mode on empty lines'] = function()
--   setup({ mappings_that_edit_in_visual = { 's' } })
--   fill_with_text({ '', '', '', '' })
--   feed('vs(')
--   lines_eq({ '(  )', '', '', '' })
--   cur_eq({ 1, 3 })
--   feed('j0.')
--   lines_eq({ '(  )', '(  )', '', '' })
--   cur_eq({ 2, 3 })
--   feed('j0vj.')
--   lines_eq({ '(  )', '(  )', '( ', ' )' })
--   cur_eq({ 3, 2 })
-- end
--
-- T['surrounds with pair char ( in V mode on empty lines'] = function()
--   setup({ mappings_that_edit_in_visual = { 's' } })
--   fill_with_text({ '', '', '', '' })
--   feed('Vs(')
--   lines_eq({ '(  )', '', '', '' })
--   cur_eq({ 1, 3 })
--   feed('j0.')
--   lines_eq({ '(  )', '(  )', '', '' })
--   cur_eq({ 2, 3 })
--   feed('j0Vj.')
--   lines_eq({ '(  )', '(  )', '( ', ' )' })
--   cur_eq({ 3, 2 })
-- end
--
-- T['surrounds with pair char ) in v mode on space chars'] = function()
--   setup({ mappings_that_edit_in_visual = { 's' } })
--   fill_with_text({ '  ', '  ', '  ', '  ' })
--   feed('vs)')
--   lines_eq({ '( ) ', '  ', '  ', '  ' })
--   cur_eq({ 1, 2 })
--   feed('j0.')
--   lines_eq({ '( ) ', '( ) ', '  ', '  ' })
--   cur_eq({ 2, 2 })
--   feed('j0vj.')
--   lines_eq({ '( ) ', '( ) ', '(  ', ' ) ' })
--   cur_eq({ 3, 2 })
-- end
--
-- T['surrounds with pair char ( in v mode on space chars'] = function()
--   setup({ mappings_that_edit_in_visual = { 's' } })
--   fill_with_text({ '  ', '  ', '  ', '  ' })
--   feed('vs(')
--   lines_eq({ '(   ) ', '  ', '  ', '  ' })
--   cur_eq({ 1, 3 })
--   feed('j0.')
--   lines_eq({ '(   ) ', '(   ) ', '  ', '  ' })
--   cur_eq({ 2, 3 })
--   feed('j0vj.')
--   lines_eq({ '(   ) ', '(   ) ', '(   ', '  ) ' })
--   cur_eq({ 3, 3 })
-- end
--
-- T['surrounds with pair char ) in V mode on space chars'] = function()
--   setup({ mappings_that_edit_in_visual = { 's' } })
--   fill_with_text({ '  ', '  ', '  ', '  ' })
--   feed('Vs)')
--   lines_eq({ '(  )', '  ', '  ', '  ' })
--   cur_eq({ 1, 2 })
--   feed('j0.')
--   lines_eq({ '(  )', '(  )', '  ', '  ' })
--   cur_eq({ 2, 2 })
--   feed('j0Vj.')
--   lines_eq({ '(  )', '(  )', '(  ', '  )' })
--   cur_eq({ 3, 2 })
-- end
--
-- T['surrounds with pair char ( in V mode on space chars'] = function()
--   setup({ mappings_that_edit_in_visual = { 's' } })
--   fill_with_text({ '  ', '  ', '  ', '  ' })
--   feed('Vs(')
--   lines_eq({ '(    )', '  ', '  ', '  ' })
--   cur_eq({ 1, 3 })
--   feed('j0.')
--   lines_eq({ '(    )', '(    )', '  ', '  ' })
--   cur_eq({ 2, 3 })
--   feed('j0Vj.')
--   lines_eq({ '(    )', '(    )', '(   ', '   )' })
--   cur_eq({ 3, 3 })
-- end
