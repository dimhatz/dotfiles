local update_treesitter_tree = require('my-helpers').update_treesitter_tree
local M = {}
local ns = vim.api.nvim_create_namespace('my-rainbow')

---@class SkippableTillEol
---@field till_eol string single delimiter, signifying comment till eol

---@class SkippableDilimitedRange
---@field delimited_range string[] at least 2 elements (starting and closing delimiter), optionally followed by 1 or more escape sequences

---@alias mySkippablePatterns (SkippableTillEol | SkippableDilimitedRange)[]

---@alias mySettings {[string]: { skippable_patterns: mySkippablePatterns, pairs: [string, string][]}}

-- if a pattern is active, this is its index, otherwise nil, only 1 pattern can be active at a time
local active_skippable_pattern_index = nil

local settings = { ---@type mySettings
  typescript = {
    skippable_patterns = {
      { till_eol = '//' },
      { delimited_range = { '/*', '*/' } },
      { delimited_range = { "'", "'", [[\']] } },
      { delimited_range = { '"', '"', [[\"]] } },
      { delimited_range = { '`', '`', [[\`]] } },
    },
    pairs = {
      { '(', ')' },
      { '{', '}' },
      { '[', ']' },
    },
  },
  lua = {
    skippable_patterns = {
      { till_eol = '--' },
      { delimited_range = { '[[', ']]' } },
      { delimited_range = { "'", "'", [[\']] } },
      { delimited_range = { '"', '"', [[\"]] } },
    },
    pairs = {
      { '(', ')' },
      { '{', '}' },
      { '[', ']' },
    },
  },
}

-- we want at top level the blue, next violet, next yellow.
local hl_groups = {
  'RainbowDelimiterBlue',
  'RainbowDelimiterViolet',
  'RainbowDelimiterYellow',
}

function M.my_rainbow_parens_refresh()
  local t_begin = os.clock()
  if vim.o.fileencoding ~= 'utf-8' then
    -- always assume utf-8
    return
  end

  local ft = vim.bo.filetype

  if not settings[ft] then
    return
  end

  local pairs_as_array_of_strings = settings[ft].pairs

  -- dicts that map opening -> closing and the other way around
  local opening_pairs_as_bytes = {} --- @type {[integer]: integer}
  local closing_pairs_as_bytes = {} --- @type {[integer]: integer}

  for _, arr in ipairs(pairs_as_array_of_strings) do
    opening_pairs_as_bytes[arr[1]:byte()] = arr[2]:byte()
    closing_pairs_as_bytes[arr[2]:byte()] = arr[1]:byte()
  end

  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

  local is_treesitter_hl_enabled = vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] and true or false
  local is_syntax_hl_enabled = vim.b.current_syntax and true or false -- is nil when syntax off
  if is_treesitter_hl_enabled then
    -- there was a bug with rainbow-delimiters plugin, where we needed to force refresh treesitter tree
    -- (due to weird nvim behavior)
    -- TODO: check whether this is also relevant here
    update_treesitter_tree()
  end

  local is_comment_or_string_time = 0.00
  ---@param line integer -- 1-based
  ---@param col integer -- 1-based
  ---@return boolean
  local function is_comment_or_string(line, col)
    local t_beg = os.clock()
    if is_treesitter_hl_enabled then
      local captures = vim.treesitter.get_captures_at_pos(0, line - 1, col - 1)
      for _, capture in ipairs(captures) do
        local capture_name = capture.capture:lower()
        if capture_name:find('comment') or capture_name:find('string') then
          is_comment_or_string_time = is_comment_or_string_time + (os.clock() - t_beg)
          return true
        end
      end
    end
    if is_syntax_hl_enabled then
      -- use synstack() to examine all the syntax items
      local syn_ids = vim.fn.synstack(line, col)
      for _, syn_id in ipairs(syn_ids) do
        local syn_name = vim.fn.synIDattr(syn_id, 'name'):lower()
        if syn_name:find('comment', 1, true) or syn_name:find('string', 1, true) then
          is_comment_or_string_time = is_comment_or_string_time + (os.clock() - t_beg)
          return true
        end
      end
    end
    is_comment_or_string_time = is_comment_or_string_time + (os.clock() - t_beg)
    return false
  end

  -- 1-byte:  0xxxxxxx                                 <-- ASCII (our case)
  -- 2-byte:  110xxxxx  10xxxxxx                       <-- 11000000 == 0xC0
  -- 3-byte:  1110xxxx  10xxxxxx  10xxxxxx             <-- 11100000 == 0xE0
  -- 4-byte:  11110xxx  10xxxxxx  10xxxxxx  10xxxxxx   <-- 11110000 == 0xF0
  -- the continuation bytes always start with 10       <-- 10000000 == 0x80

  -- key: the opening paren as byte
  -- value: actual (not byte) character positions, as displayed in buffer, 1-based
  local positions = {} ---@type {[integer]: [integer, integer][]}
  for key, _ in pairs(opening_pairs_as_bytes) do
    positions[key] = {}
  end

  -- highlighting: we want parens on the same level to be the same color eg: ()()()[][][] should have
  -- the same color, the inner parens must alternate colors, as the level goes deeper.
  -- To achieve this, we increase the count below when we add an opening paren on the stack, we decrease it when
  -- we do the highlighting. Taking `count modulo 3` (for our 3 colors) guarantees the correct cycling between the colors.
  local curr_hl_color_count = 0 -- to be used with modulo 3 to select hl group

  ---@param pos1 [integer, integer]
  ---@param pos2 [integer, integer]
  --- positions are 1-based
  local function highlight_pair(pos1, pos2)
    if not pos1 or not pos2 then
      -- vim.print('My rainbow: unbalanced parens')
      return
    end

    curr_hl_color_count = curr_hl_color_count - 1
    local hl_group = hl_groups[(curr_hl_color_count % 3) + 1]

    -- accepts 0-based ranges, so we decrease all indexes by 1
    vim.hl.range(0, ns, hl_group, { pos1[1] - 1, pos1[2] - 1 }, { pos1[1] - 1, pos1[2] - 1 + 1 })
    vim.hl.range(0, ns, hl_group, { pos2[1] - 1, pos2[2] - 1 }, { pos2[1] - 1, pos2[2] - 1 + 1 })
  end

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for line_nr = 1, #lines do
    local line_text = lines[line_nr] -- #line is the number of bytes

    local line_len = #line_text
    local byte_idx = 1
    local bytes_skipped = 0

    -- iterate each byte of the string, skipping any multibyte chars
    while byte_idx <= line_len do
      local cur_byte = line_text:byte(byte_idx)

      if cur_byte >= 0xF0 then
        -- 4-byte sequence
        bytes_skipped = bytes_skipped + 3
        byte_idx = byte_idx + 4
        goto continue
      elseif cur_byte >= 0xE0 then
        -- 3-byte sequence
        bytes_skipped = bytes_skipped + 2
        byte_idx = byte_idx + 3
        goto continue
      elseif cur_byte >= 0xC0 then
        -- 2-byte sequence
        bytes_skipped = bytes_skipped + 1
        byte_idx = byte_idx + 2
        goto continue
      elseif cur_byte >= 0x80 then
        -- we got a continuation sequence, this should never happen, since we jump over all the continuations
        vim.print('my rainbow: got continuation sequence. Will not highlight any parens.')
        return
      else
        -- ascii, this is what we are interested in
        local col = byte_idx - bytes_skipped -- actual position

        -- checking for not being part of comment or string only after we have determined we have a
        -- bracket on current position.
        if opening_pairs_as_bytes[cur_byte] and not is_comment_or_string(line_nr, col) then
          -- we got an opening paren
          table.insert(positions[cur_byte], { line_nr, col })
          curr_hl_color_count = curr_hl_color_count + 1
        elseif closing_pairs_as_bytes[cur_byte] and not is_comment_or_string(line_nr, col) then
          -- we got a closing paren
          local matching_opening_pair = closing_pairs_as_bytes[cur_byte]
          highlight_pair(table.remove(positions[matching_opening_pair]), { line_nr, col })
        end
        byte_idx = byte_idx + 1
      end

      ::continue::
    end
  end
  -- vim.print('My rainbow parens done in: ' .. (os.clock() - t_begin) * 1000 .. ' ms')
  -- vim.print('is_comment_or_string_time: ' .. is_comment_or_string_time * 1000 .. ' ms')
  -- in lua, measure how much time (in ms) a function took to execute
end

return M
