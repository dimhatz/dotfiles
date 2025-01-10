local remap = require('my-helpers').remap
local reverse_in_place = require('my-helpers').reverse_in_place
local concat_arrays = require('my-helpers').concat_arrays

local ns_dimming = vim.api.nvim_create_namespace('myjump_dimming')
local ns_spots = vim.api.nvim_create_namespace('myjump_spots')

---@enum Granularity
local Granularity = {
  line = 1,
  word = 2,
}

---@enum Direction
local Direction = {
  forward = 1,
  back = 2,
}

---@enum MatchSide
local MatchSide = {
  word_start = 1,
  word_end = 2,
}

---@param spots [integer,integer][]
---@param cursor_col integer
---Filters out (in-place) the two closest spots to the cursor position, these are accessible by simple moves b,w,e
local function filter_out_easy_spots(spots, cursor_col)
  -- TODO: improve
  if #spots < 2 then
    return
  end

  local closest_left_index = 1
  local closest_right_index = #spots

  for i, spot in ipairs(spots) do
    if spot[2] > cursor_col then
      closest_right_index = i
      break
    end
  end

  -- closest_right_index could actually be to the left of the cursor
  if closest_right_index > 1 and spots[closest_right_index][2] > cursor_col then
    closest_left_index = closest_right_index - 1
  else
    closest_left_index = closest_right_index
  end

  -- we have a spot exactly on cursor pos, so we want to remove an additional spot, to its left
  if spots[closest_left_index][2] == cursor_col and closest_left_index > 1 then
    closest_left_index = closest_left_index - 1
  end

  for _ = closest_left_index, closest_right_index do
    -- removing the same (closest_left_index), since the following elements will be shifted
    table.remove(spots, closest_left_index)
  end
end

---@param line_nr integer
---@param granularity Granularity
---@param direction Direction
---@param match_side MatchSide
---@param cursor_line integer
---@param cursor_col integer
---@return [integer,integer][]
---Returns an array of spots: [row, col], 1-based?, ordered always left-to-right, for a line
local function get_spots_per_line(line_nr, granularity, direction, match_side, cursor_line, cursor_col)
  if vim.fn.foldclosed(line_nr) ~= -1 then
    -- skip lines in fold
    return {}
  end

  local spots_per_line = {} ---@type [integer, integer][]

  -- from by mini.jump2d:
  local line_text = vim.fn.getline(line_nr)
  -- '(()[^%s%p]+)' -- :h lua-patterns, from mini.jump2d, to support multibyte chars
  -- extra parens are for capture groups: the outer for the whole matched word, the inner
  -- empty () for position/index (1-based)
  for word, index in string.gmatch(line_text, '(()[^%s%p]+)') do
    if granularity == Granularity.line and #spots_per_line > 0 then
      -- we already processed our first match
      break
    end

    if match_side == MatchSide.word_end then
      index = index + math.max(word:len() - 1, 0)
    end

    -- Ensure that index is strictly within line length (which can be not
    -- true in case of weird pattern, like when using frontier `%f[%W]`)
    index = math.min(math.max(index, 0), line_text:len())

    -- Unify how spot is chosen in case of multibyte characters
    -- Use `+-1` to make sure that result it at start of multibyte character
    local utf_index = vim.str_utfindex(line_text, index) - 1
    index = vim.str_byteindex(line_text, utf_index) + 1

    -- skip those spots that are on the same line as the cursor but on the opposite side
    -- to the direction
    if line_nr == cursor_line then
      if granularity == Granularity.line then
        goto continue1
      end
      if direction == Direction.back and index >= cursor_col then
        goto continue1
      end
      if direction == Direction.forward and index <= cursor_col then
        goto continue1
      end
    end

    table.insert(spots_per_line, { line_nr, index })
    ::continue1::
  end

  -- Filter out the two closest spots to the cursor position, these are accessible by simple moves b,w,e
  if
    granularity == Granularity.word
    and (
      line_nr == cursor_line
      or (direction == Direction.forward and line_nr == cursor_line + 1)
      or (direction == Direction.back and line_nr == cursor_line - 1)
    )
  then
    filter_out_easy_spots(spots_per_line, cursor_col)
  end

  return spots_per_line
end

---@param direction Direction
---@param granularity Granularity
---@param side MatchSide
local function jump(direction, granularity, side)
  local top_line = vim.fn.line('w0') -- 1-based
  local bot_line = vim.fn.line('w$') -- 1-based
  local _, cursor_line, cursor_col = unpack(vim.fn.getcurpos()) -- 1-based, unlike vim.api.nvim_win_get_cursor()

  -- accumulate jump spots [line, col] by querying each line with regex
  local start_line = top_line
  local end_line = bot_line
  local spots = {} ---@type [integer, integer][]
  if direction == Direction.forward then
    if granularity == Granularity.line then
      start_line = cursor_line + 1
    else
      start_line = cursor_line -- Granularity: word
    end
  else -- Direction: back
    if granularity == Granularity.line then
      end_line = cursor_line - 1
    else
      end_line = cursor_line -- Granularity: word
    end
  end

  for line_nr = start_line, end_line do
    local spots_per_line = get_spots_per_line(line_nr, granularity, direction, side, cursor_line, cursor_col)
    concat_arrays(spots, spots_per_line)
  end

  if direction == Direction.back then
    reverse_in_place(spots)
  end

  if #spots == 0 then
    return
  end

  -- apply dimming extmarks
  local extmark_start_line = start_line - 1 -- 0 based, inclusive
  local extmark_end_line = end_line -- 0 based, exclusive
  -- mini.jump2d also sets `end_col = 0`, we just skip it
  vim.api.nvim_buf_set_extmark(0, ns_dimming, extmark_start_line, 0, { end_row = extmark_end_line, hl_group = 'Comment', priority = 999 })

  -- apply spots extmarks
  for _, spot in ipairs(spots) do
    vim.api.nvim_buf_set_extmark(
      0,
      ns_spots,
      spot[1] - 1,
      spot[2] - 1,
      -- , hl_group = 'MyHop'
      { end_col = spot[2] - 1 + 2, priority = 1000, virt_text = { { 'ZX', 'MyHop' } }, hl_mode = 'combine', virt_text_pos = 'overlay' }
    )
  end

  -- local ok, key = pcall(vim.fn.getcharstr)
end

---@param ns_id integer
local function remove_extmarks(ns_id)
  -- pcall(vim.api.nvim_buf_clear_namespace, 0, ns, 0, -1)
  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
end

-- remap('n', '<Leader>z', function()
--   jump(Direction.forward, Granularity.line, MatchSide.word_start)
-- end, { desc = 'New' })
remap('n', '<Leader>x', function()
  remove_extmarks(ns_dimming)
  remove_extmarks(ns_spots)
end, { desc = 'New' })
remap('n', '<Leader>zz', function()
  jump(Direction.forward, Granularity.word, MatchSide.word_start)
end, { desc = 'Test' })
remap('n', '<Leader>zx', function()
  jump(Direction.back, Granularity.word, MatchSide.word_start)
end, { desc = 'Test' })
