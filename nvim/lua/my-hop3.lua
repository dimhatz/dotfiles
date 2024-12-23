local remap = require('my-helpers').remap
local reverse_in_place = require('my-helpers').reverse_in_place

local ns = vim.api.nvim_create_namespace('myjump')

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

local function get_spots_per_line(line_nr, granularity, direction, side, cursor_line, cursor_col)
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

    -- TODO: do not show indexes on the other side of the cursor in cursor line

    if side == MatchSide.word_end then
      index = index + math.max(word:len() - 1, 0)
    end

    -- Ensure that index is strictly within line length (which can be not
    -- true in case of weird pattern, like when using frontier `%f[%W]`)
    index = math.min(math.max(index, 0), line_text:len())

    -- Unify how spot is chosen in case of multibyte characters
    -- Use `+-1` to make sure that result it at start of multibyte character
    local utf_index = vim.str_utfindex(line_text, index) - 1
    index = vim.str_byteindex(line_text, utf_index) + 1

    table.insert(spots_per_line, { line_nr, index })
    if direction == Direction.back then
      reverse_in_place(spots_per_line)
    end
  end

  return spots_per_line
end

---@param direction Direction
---@param granularity Granularity
---@param side MatchSide
local function jump(direction, granularity, side)
  local top_line = vim.fn.line('w0') -- 1-based
  local bot_line = vim.fn.line('w$') -- 1-based
  local _, cursor_line, cursor_col = unpack(vim.fn.getcurpos()) -- 1-based

  -- dimming
  local dim_top_line = top_line - 1 -- 0 based, inclusive
  local dim_bot_line = bot_line -- 0 based, exclusive
  if direction == Direction.back then
    dim_bot_line = cursor_line
  else
    dim_top_line = cursor_line - 1
  end
  -- mini.jump2d also sets `end_col = 0`, we just skip it
  vim.api.nvim_buf_set_extmark(0, ns, dim_top_line, 0, { end_row = dim_bot_line, hl_group = 'Comment', priority = 999 })

  -- accumulate jump spots [line, col] by querying each line with regex
  local start_line = 1
  local end_line = 1
  local step = 1
  local spots = {} ---@type [integer, integer][]
  if direction == Direction.back then
    start_line = cursor_line
    end_line = top_line
    step = -1
  else
    start_line = cursor_line
    end_line = bot_line
    step = 1
  end

  for line_nr = start_line, end_line, step do
    local spots_per_line = get_spots_per_line(line_nr, granularity, direction, side, cursor_line, cursor_col)
    table.insert(spots, spots_per_line)
  end
end

local function remove_extmarks()
  -- pcall(vim.api.nvim_buf_clear_namespace, 0, ns, 0, -1)
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
  vim.print('cleared')
end

remap('n', '<Leader>z', function()
  jump(Direction.forward, Granularity.line, MatchSide.word_start)
end, { desc = 'New' })
remap('n', '<Leader>x', remove_extmarks, { desc = 'New' })
