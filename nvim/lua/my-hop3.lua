local remap = require('my-helpers').remap
local reverse_in_place = require('my-helpers').reverse_in_place
local concat_arrays = require('my-helpers').concat_arrays
local slice_array = require('my-helpers').slice_array

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

-- ------------------------------- Targets / labels / permutations
local LETTERS_STR = 'ASDFGHJKLQWERTYUIOPZXCVBNM'
local LETTERS = vim.split(LETTERS_STR, '')
local LETTERS_NUM = #LETTERS
local MIN_L1_LABELS = 10
local MAX_L3_LABELS = 1
local MAX_SPOTS = MIN_L1_LABELS + (LETTERS_NUM - MIN_L1_LABELS - MAX_L3_LABELS) * LETTERS_NUM + (LETTERS_NUM ^ 2) -- 1076

if MAX_SPOTS ~= 1076 then
  vim.notify('My hop: Assertion for number of spots failed!', vim.log.levels.ERROR)
end

if #LETTERS ~= 26 then
  vim.notify('My hop: Assertion for number letters failed!', vim.log.levels.ERROR)
end

---@param spots_num  integer
---@return integer, integer, integer
---Returns the number of letters split between l1/l2/l3-type targets, so that their
---permutations are enough to cover the number of spots (<-param) required.
local function calculate_letter_amount(spots_num)
  -- There are 26 letters in english alphabet. Permutations:
  -- 1-letter only (l1: length 1) targets: 26
  -- 2-letter only (l2: length 2) targets: 26^2 -> 676
  -- 3-letter only (l3: length 3) targets: 26^3 -> 17576
  -- We have to determine how many 1-letter, 2-letter, 3-letter permutations will
  -- be used.
  -- l1 + l2 + l3 = 26
  -- l1 + (l2 * 26) + (l3 * 26^2) = spots_num
  -- Personal preference:
  -- We want to spend at most 1 letter as a starting letter for l3 targets (MAX_L3_LABELS).
  -- We want to spend at least 10 letter as a starting letter for l1 targets (MIN_L1_LABELS).
  -- The rest of the letters become starting letters for l2 targets.

  local l1_labels_num = 0
  local l2_labels_num = 0
  local l3_labels_num = 0
  if spots_num > MAX_SPOTS then
    vim.notify('My hop: This should never happen. Got too many labels')
    return 0, 0, 0
  end
  if spots_num <= LETTERS_NUM then
    -- only l1 labels are enough
    l1_labels_num = LETTERS_NUM
    l2_labels_num = 0
    l3_labels_num = 0
  elseif spots_num <= MIN_L1_LABELS + ((LETTERS_NUM - MIN_L1_LABELS) * LETTERS_NUM) then
    -- only l1 and l2 labels are enough. Calculation:
    -- l1 = 10, l2 = 16 -> 10 + 16 * 26 == 426, so spots_num here should be <= 426
    -- Now we determine how what will be the split for l1/l2 letters:
    -- counting down, starting at letters - 1, since 26 (LETTERS) is not enough for l1-only case,
    -- otherwise it would have been handled above.
    for curr_l1 = LETTERS_NUM - 1, MIN_L1_LABELS, -1 do
      if spots_num <= curr_l1 + (LETTERS_NUM - curr_l1) * LETTERS_NUM then
        l1_labels_num = curr_l1
        l2_labels_num = LETTERS_NUM - curr_l1
        l3_labels_num = 0
        break
      end
    end
  elseif spots_num <= MAX_SPOTS then
    -- we will need some l3 labels, so we minimize them, by maximizing l2,
    -- while still having l1 at 10.
    l1_labels_num = MIN_L1_LABELS
    l3_labels_num = 1
    l2_labels_num = LETTERS_NUM - l3_labels_num - l1_labels_num
  end
  -- sanity check
  if l1_labels_num == 0 then
    vim.notify('My hop: This should never happen. Bad calculation for `2-letter labels only` case')
    return 0, 0, 0
  end
  return l1_labels_num, l2_labels_num, l3_labels_num
end

---@class MyNode -- Node is taken by lua lib
---@field spot [integer, integer]?
---@field [string] MyNode -- string is a single letter,
---all the unnamed single-letter fields are the children of this node

---@param spots [integer,integer][]
---@return  MyNode
local function create_target_tree(spots)
  local l1_num, _, l3_num = calculate_letter_amount(#spots)
  -- We assign the first l1_num letters for the l1-type permutations.
  -- We assign the last letter for l3-type permutation (if there is an l3).
  -- We assign the rest of letters to l2, starting from the end of the array,
  -- towards the middle. The reason for this is so that we can put the
  -- most comfortable letters in the beginning and the end of the array,
  -- the least comfortable in the middle. This way, the starting letter of l1 / l2 / l3
  -- will be a comfortable one.
  local l1_start_letters = slice_array(LETTERS, 1, l1_num + 1)
  local l2_start_letters = slice_array(LETTERS, l1_num + 1, LETTERS_NUM + 1 - l3_num)
  reverse_in_place(l2_start_letters)
  local l3_start_letter = LETTERS[#LETTERS]
  -- assertion
  if #l1_start_letters + #l2_start_letters + l3_num ~= LETTERS_NUM then
    vim.notify('Incorrectly assigned letters to l1, l2, l3', vim.log.levels.ERROR)
    return {}
  end

  local next_spot_index = 1

  local res = {} ---@type MyNode

  -- vim.print(l1_start_letters)
  -- vim.print(l2_start_letters)

  -- l1
  for _, l1_start_letter in ipairs(l1_start_letters) do
    if next_spot_index > #spots then
      return res
    end
    res[l1_start_letter] = { spot = spots[next_spot_index] } -- l1 node
    next_spot_index = next_spot_index + 1
  end

  -- l2
  for _, l2_start_letter in ipairs(l2_start_letters) do
    -- additional check in case the previous iteration has stopped right at the last spot
    if next_spot_index > #spots then
      return res
    end
    local l2_node = {} ---@type MyNode -- no spot, since this is not the leaf
    res[l2_start_letter] = l2_node
    -- permutations
    for _, l2_second_letter in ipairs(LETTERS) do
      if next_spot_index > #spots then
        return res
      end
      l2_node[l2_second_letter] = { spot = spots[next_spot_index] }
      next_spot_index = next_spot_index + 1
    end
  end

  -- l3
  if l3_num == 0 or next_spot_index > #spots then
    return res
  end

  local l3_node = {}
  res[l3_start_letter] = l3_node

  for _, l3_second_letter in ipairs(LETTERS) do
    -- additional check in case the previous iteration has stopped right at the last spot
    if next_spot_index > #spots then
      return res
    end
    local l3_second_node = {}
    l3_node[l3_second_letter] = l3_second_node
    for _, l3_third_letter in ipairs(LETTERS) do
      -- additional check in case the previous iteration has stopped right at the last spot
      if next_spot_index > #spots then
        return res
      end
      l3_second_node[l3_third_letter] = { spot = spots[next_spot_index] }
      next_spot_index = next_spot_index + 1
    end
  end

  return res
end

---@param node MyNode
---@param letters_so_far string
---Traverses the tree to apply highlighted labels for each spot
local function apply_labels(node, letters_so_far)
  local spot = node.spot
  if spot ~= nil then
    vim.api.nvim_buf_set_extmark(
      0,
      ns_spots,
      spot[1] - 1, -- -1 to make it 0-based
      spot[2] - 1, -- -1 to make it 0-based
      { priority = 1000, virt_text = { { letters_so_far, 'MyHop' } }, hl_mode = 'combine', virt_text_pos = 'overlay' }
    )
    return
  end
  for letter, child_node in pairs(node) do
    if #letter ~= 1 then
      vim.notify('My hop: expected single letter but got more', vim.log.levels.ERROR)
      return
    end
    apply_labels(child_node, letters_so_far .. letter)
  end
end

---@param ns_id integer
local function remove_extmarks(ns_id)
  -- pcall(vim.api.nvim_buf_clear_namespace, 0, ns, 0, -1)
  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
end

-- local t_begin = 0

---@param node MyNode
local function perform_jump(node)
  remove_extmarks(ns_spots)
  apply_labels(node, '')
  vim.cmd.redraw()
  -- vim.print(os.clock() - t_begin)
  local key = vim.fn.getcharstr():upper() -- hop and jump2d use pcall(vim.fn.getcharstr)
  local child_node = node[key]
  if child_node == nil then
    -- input does not match anything
    return
  end
  local spot = child_node.spot
  if spot ~= nil then
    -- input matches a spot
    vim.cmd("normal! m'")
    vim.api.nvim_win_set_cursor(0, { spot[1], spot[2] - 1 }) -- 1,0-based
    return
  end
  -- more inputs are needed
  perform_jump(child_node)
  -- vim.cmd.redraw()
end

-- ------------------------------ Spots / coordinates

-- A spot is an [integer, integer] pair, to signify location withing the buffer text, 1-based
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
  -- t_begin = os.clock()
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

  -- we don't display > 1076 spots
  if #spots > MAX_SPOTS then
    spots = slice_array(spots, 1, MAX_SPOTS + 1)
  end

  -- apply dimming extmarks
  local extmark_start_line = start_line - 1 -- 0 based, inclusive
  local extmark_end_line = end_line -- 0 based, exclusive
  -- mini.jump2d also sets `end_col = 0`, we just skip it
  vim.api.nvim_buf_set_extmark(0, ns_dimming, extmark_start_line, 0, { end_row = extmark_end_line, hl_group = 'MyHopDimming', priority = 999 })

  local node = create_target_tree(spots)
  perform_jump(node)
  remove_extmarks(ns_spots)
  remove_extmarks(ns_dimming)
end

-- remap('n', '<Leader>z', function()
--   jump(Direction.forward, Granularity.line, MatchSide.word_start)
-- end, { desc = 'New' })
remap('n', '<Leader>x', function()
  remove_extmarks(ns_dimming)
  remove_extmarks(ns_spots)
end, { desc = 'New' })

remap({ 'n', 'v' }, 'f', function()
  jump(Direction.forward, Granularity.word, MatchSide.word_start)
end, { desc = 'Jump forward' })

remap({ 'n', 'v' }, 't', function()
  jump(Direction.back, Granularity.word, MatchSide.word_start)
end, { desc = 'Jump back (towards top)' })

remap({ 'n', 'v' }, '<Leader>k', function()
  jump(Direction.back, Granularity.line, MatchSide.word_start)
end, { desc = 'Jump back linewise' })

remap({ 'n', 'v' }, '<Leader>j', function()
  jump(Direction.forward, Granularity.line, MatchSide.word_start)
end, { desc = 'Jump forward linewise' })

remap({ 'n', 'v' }, '<Leader>e', function()
  jump(Direction.forward, Granularity.word, MatchSide.word_end)
end, { desc = 'Jump forward to the end of a word' })
