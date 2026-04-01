local M = {}
local ns = vim.api.nvim_create_namespace('my-rainbow')

-- Definitions:
-- skippable: a comment (both delimited and till eol) or a string (optionally with escape char <- single byte)
-- paren: a round paren, a square bracket or a curly brace
-- idx: byte-index into a string, does not necessarily align with the beginning of a UTF-8 char
-- col: the position of the UTF-8 char (all the preceding bytes were interpreted as UTF-8) -> not
-- needed so far, since in vim's apis column is actually the byte index (eg for highlighting).
-- delimiter: either a closing or opening sequence for either a paren or a skippable

---@class Skippable
---@field closing_delimiter string? when absent, it's comment till eol
---@field escape_char string? if exists, assumed to be exactly 1-char long

--- the top level key is the language, the key in skippable_patterns is the opening delimiter
---@alias mySettings {[string]: { skippable_patterns: {[string]:  Skippable }, parens: [string, string][]}}

local settings = { ---@type mySettings
  typescript = {
    -- TODO: implement highlighting TODO: annotations inside comments.
    skippable_patterns = {
      ['//'] = {},
      ['/*'] = { closing_delimiter = '*/' },
      ['"'] = { closing_delimiter = '"', escape_char = [[\]] },
      ["'"] = { closing_delimiter = "'", escape_char = [[\]] },
      ['`'] = { closing_delimiter = '`', escape_char = [[\]] },
    },
    parens = {
      { '(', ')' },
      { '{', '}' },
      { '[', ']' },
    },
  },
  lua = {
    skippable_patterns = {
      ['--'] = {},
      ['[['] = { closing_delimiter = ']]' }, -- no escaping here (multiline string)
      ['[=['] = { closing_delimiter = ']=]' }, -- no escaping here (multiline string)
      ['[==['] = { closing_delimiter = ']==]' }, -- no escaping here (multiline string)
      ['--[['] = { closing_delimiter = ']]' }, -- no escaping here (multiline comment)
      ['--[=['] = { closing_delimiter = ']=]' }, -- no escaping here (multiline comment)
      ['--[==['] = { closing_delimiter = ']==]' }, -- no escaping here (multiline comment)
      ['"'] = { closing_delimiter = '"', escape_char = [[\]] },
      ["'"] = { closing_delimiter = "'", escape_char = [[\]] },
    },
    parens = {
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

local ffi = require('ffi')
-- fast way to convert column index from byte index of utf-8 string, using ffi
---@param str string
---@param pos integer
---@return integer column
---@diagnostic disable-next-line: unused-local, unused-function
local function byte_idx_to_col(str, pos)
  -- utf-8:
  -- 1-byte:  0xxxxxxx                                 <-- ASCII (our case)
  -- 2-byte:  110xxxxx  10xxxxxx                       <-- 11000000 == 0xC0
  -- 3-byte:  1110xxxx  10xxxxxx  10xxxxxx             <-- 11100000 == 0xE0
  -- 4-byte:  11110xxx  10xxxxxx  10xxxxxx  10xxxxxx   <-- 11110000 == 0xF0
  -- the continuation bytes always start with 10       <-- 10000000 == 0x80

  local ptr = ffi.cast('const uint8_t *', str)
  local char_pos = 1
  -- count how many non-continuation bytes there are, up to (but not including) byte_pos.
  -- zero-based iteration (c ffi), luajit should optimize this to be very fast.
  -- byte_pos-2 is to avoid counting byte_pos, since our count starts at 1.
  for i = 0, pos - 2 do
    local b = ptr[i]
    if b < 0x80 or b >= 0xC0 then
      char_pos = char_pos + 1
    end
  end
  return char_pos
end

function M.my_rainbow_parens_refresh()
  local t_begin = os.clock()
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

  if vim.o.fileencoding ~= 'utf-8' then
    -- always assume utf-8
    return
  end

  local curr_settings = settings[vim.bo.filetype]
  if not curr_settings then
    -- unknown filetype
    return
  end

  local parens_as_tuples = curr_settings.parens

  -- dicts that map opening -> closing
  local opening_parens_map = {} --- @type {[string]: string}
  -- dicts that map opening -> closing
  local closing_parens_map = {} --- @type {[string]: string}
  local opening_parens_locations = {} --- @type {[string]: [integer, integer]}

  for _, arr in ipairs(parens_as_tuples) do
    opening_parens_map[arr[1]] = arr[2]
    closing_parens_map[arr[2]] = arr[1]
    opening_parens_locations[arr[1]] = {} -- init
  end

  local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
  if not lang then
    -- no ts for filetype
    return
  end

  local parser = vim.treesitter.get_parser(nil, lang, { error = false })
  if not parser then
    -- there is no treesitter parser
    return
  end

  --- this is where things get done
  ---@param err string
  ---@param trees TSTree[]
  local function on_parse(err, trees) -- async
    if err then
      vim.print('my rainbow paren: TS parser failed')
      return
    end

    local root = trees[1]:root()
    local dfs_stack = { root } ---@type TSNode[]
    local dfs_stack_len = 1
    local hl_count = 0
    local hl_groups_len = #hl_groups

    repeat
      -- pop
      local node = table.remove(dfs_stack) ---@type TSNode
      dfs_stack_len = dfs_stack_len - 1

      -- when type matches, it must be anonymous leaf node
      local node_type = node:type()
      if opening_parens_map[node_type] then
        -- its an opening paren
        local open_line, open_idx = node:start() -- 0-based
        table.insert(opening_parens_locations[node_type], { open_line, open_idx })
        hl_count = hl_count + 1
      else
        local matched_opener = closing_parens_map[node_type]
        if matched_opener then
          -- its a closing paren
          local closing_line, closing_idx = node:start() -- 0-based
          local opener_pos = table.remove(opening_parens_locations[matched_opener]) ---@type [integer, integer]?
          if not opener_pos then
            -- unbalanced paren, just skip it
            goto continue_until
          end
          hl_count = hl_count - 1
          local hl_color = hl_groups[(hl_count % hl_groups_len) + 1]
          -- TODO: do not hardcode lengh of the paren (1)
          vim.hl.range(0, ns, hl_color, { opener_pos[1], opener_pos[2] }, { opener_pos[1], opener_pos[2] + 1 })
          vim.hl.range(0, ns, hl_color, { closing_line, closing_idx }, { closing_line, closing_idx + 1 })
        else
          -- its non-paren node
          local ch_count = node:child_count()
          -- reverse order of pushing for dfs
          for i = ch_count - 1, 0, -1 do
            -- push
            table.insert(dfs_stack, node:child(i))
            dfs_stack_len = dfs_stack_len + 1
          end
        end
      end
      ::continue_until::
    until dfs_stack_len == 0
  end

  vim.print('My rainbow parens done in: ' .. (os.clock() - t_begin) * 1000 .. ' ms')
  parser:parse(true, on_parse)
end

-- -- iterate captures method:
-- local processed_settings = {} ---@type {[string]: { open_parens_map: {[string]: string}, closing_parens_map: {[string]: string}, derived_ts_query: string }}
-- for lang, lang_setting in pairs(settings) do
--   local processed_lang_setting = { open_parens_map = {}, closing_parens_map = {} } ---@type { open_parens_map: {[string]: string}, closing_parens_map: {[string]: string}, derived_ts_query: string }
--   local ts_query = '[' -- assembled query looks like: ["(" "[" "{"] @opener
--   -- populate the open/closing parens maps and build the treesitter query in the same loop
--   for _, parens_pair in ipairs(lang_setting.parens) do
--     processed_lang_setting.open_parens_map[parens_pair[1]] = parens_pair[2]
--     processed_lang_setting.closing_parens_map[parens_pair[2]] = parens_pair[1]
--
--     ts_query = ts_query .. [[ "]] .. parens_pair[1] .. [["]]
--   end
--   ts_query = ts_query .. '] @opener'
--   processed_lang_setting.derived_ts_query = ts_query
--   processed_settings[lang] = processed_lang_setting
-- end

-- for _, node, _ in query:iter_captures(root, 0) do
--   local start_line, start_idx = node:start() -- 0-based
--   local parent = node:parent()
--   if not parent then
--     vim.print('My rainbow: parent not found. This should never happen')
--     return
--   end
--   local closing_node = parent:child(parent:child_count() - 1)
--   if not closing_node then
--     vim.print('My rainbow: closing node not found. This should never happen')
--     return
--   end
--   local end_line, end_idx = closing_node:start()
--   vim.hl.range(0, ns, hl_groups[1], { start_line, start_idx }, { start_line, start_idx + 1 })
--   vim.hl.range(0, ns, hl_groups[1], { end_line, end_idx }, { end_line, end_idx + 1 })
-- end

-- local handle_paren ---@type fun(str: string, line: integer, col: integer)
-- do
--   -- use do-block to encapsulate variables enclosed in handle_paren() and initialize it.
--   -- highlighting: we want parens on the same level to be the same color eg: ()()()[][][] should have
--   -- the same color, the inner parens must alternate colors, as the level goes deeper.
--   -- To achieve this, we increase the count below when we add an opening paren on the stack, we decrease it when
--   -- we do the highlighting. Taking `count modulo 3` (for our 3 colors) guarantees the correct cycling between the colors.
--   local curr_hl_color_count = 0 -- to be used with modulo 3 to select hl group
--   -- map paren as string -> array of opening positions, at which this paren was found
--   local positions = {} ---@type {[string]: [integer, integer][]}
--   for _, arr in ipairs(parens_as_tuples) do
--     positions[arr[1]] = {}
--   end
--   local modulo = #hl_groups
--
--   ---@param str string
--   ---@param line integer
--   ---@param col integer
--   local function handle_paren_impl(str, line, col)
--     if opening_parens_map[str] then
--       table.insert(positions[str], { line, col })
--       curr_hl_color_count = curr_hl_color_count + 1
--       return
--     end
--
--     -- we got a closing paren, so we highlight the pair and decrease the color count
--     local matching_opening_paren = closing_parens_map[str]
--     local matching_pos = table.remove(positions[matching_opening_paren])
--     if not matching_pos then
--       -- vim.print('My rainbow: unbalanced parens')
--       return
--     end
--
--     curr_hl_color_count = curr_hl_color_count - 1
--     local hl_group = hl_groups[curr_hl_color_count % modulo + 1]
--
--     -- accepts 0-based ranges, so we decrease all indexes by 1
--     vim.hl.range(0, ns, hl_group, { line - 1, col - 1 }, { line - 1, col - 1 + 1 })
--     vim.hl.range(0, ns, hl_group, { matching_pos[1] - 1, matching_pos[2] - 1 }, { matching_pos[1] - 1, matching_pos[2] - 1 + 1 })
--   end
--   handle_paren = handle_paren_impl
-- end
--
-- local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
-- local lines_len = #lines
-- if lines_len > 20000 then
--   -- skip large files just in case
--   return
-- end
--
-- -- Only 1 pattern can be active at a time.
--
-- -- we search for these when NOT inside skippable sequence, so these are opening and closing parens, opening (but not closing) skippable delimiters
-- local delimiters_for_non_skippable = {} ---@type string[]
-- for opening_skippable, _ in pairs(curr_settings.skippable_patterns) do
--   table.insert(delimiters_for_non_skippable, opening_skippable)
-- end
-- for _, paren_pair in ipairs(curr_settings.parens) do
--   table.insert(delimiters_for_non_skippable, paren_pair[1])
--   table.insert(delimiters_for_non_skippable, paren_pair[2])
-- end
-- -- sorting is needed to be able to iterate short sequences first, so that, if there
-- -- are openers that start with the same sequence (like [ and [[ in lua), the longest match will win.
-- table.sort(delimiters_for_non_skippable)
-- local delimiters_for_non_skippable_len = #delimiters_for_non_skippable
--
-- local inside_delimited_skippable = nil ---@type string? nil for "not inside a skippable" has to be outside, since these can be multiline
-- for line_nr = 1, lines_len do
--   local line_text = lines[line_nr]
--   local next_search_start_idx = 1
--
--   repeat -- to run at least once
--     if inside_delimited_skippable then
--       -- we are inside delimited skippable, so we only search for the closing delimiter of the skippable
--       local closing_skippable_delimiter = curr_settings.skippable_patterns[inside_delimited_skippable].closing_delimiter
--       if not closing_skippable_delimiter then
--         vim.print('My rainbow: closing delimiter not found. this should never happen.')
--         return
--       end
--       local start_idx, end_idx = line_text:find(closing_skippable_delimiter, next_search_start_idx, true) -- true for plain text mode, for speed
--       if not start_idx then
--         -- closing delimiter not found, we are still inside skippable, break and continue to the next line
--         break
--       end
--
--       -- check for potential escape char
--       local escape_char = curr_settings.skippable_patterns[inside_delimited_skippable].escape_char
--       if escape_char and start_idx > 1 then
--         -- there is a possibility that there is a preceding escape char
--         local potential_esc_char_idx = start_idx - 1
--         if escape_char:byte(1) == line_text:byte(potential_esc_char_idx) then
--           -- the char on start_idx was negated by escape char, we continue searching starting with the next char
--           next_search_start_idx = start_idx + 1
--         else
--           -- the skippable delimiter was closed, we are no longer inside skippable
--           inside_delimited_skippable = nil
--           next_search_start_idx = end_idx + 1
--         end
--       else
--         -- the skippable delimiter was closed, we are no longer inside skippable
--         inside_delimited_skippable = nil
--         next_search_start_idx = end_idx + 1
--       end
--     else
--       -- we are not inside delimited skippable, find the nearest opening delimiter of any kind
--       local nearest_delimiter = nil ---@type string?
--       local nearest_dilimiter_byte_idx_start = math.huge -- infinity, only valid if nearest_delimiter is not nil
--       local nearest_dilimiter_byte_idx_end = math.huge -- infinity, only valid if nearest_delimiter is not nil
--       for i = 1, delimiters_for_non_skippable_len do
--         local delimiter = delimiters_for_non_skippable[i]
--         local start_idx, end_idx = line_text:find(delimiter, next_search_start_idx, true) -- true for plain text mode, for speed
--         -- checking with <= in case there are sequences starting with the same chars, like in lua: [ and [[.
--         -- since delimiters_for_non_skippable is sorted (ascending), we are guaranteed to check the smaller
--         -- strings first.
--         if start_idx and start_idx <= nearest_dilimiter_byte_idx_start and end_idx then
--           nearest_delimiter = delimiter
--           nearest_dilimiter_byte_idx_start = start_idx
--           nearest_dilimiter_byte_idx_end = end_idx
--         end
--       end
--       if not nearest_delimiter then
--         -- no relevant delimiters were found
--         break
--       end
--       -- what kind of delimeter was found?
--       local skippable = curr_settings.skippable_patterns[nearest_delimiter]
--       if skippable then
--         -- it's an (opening) skippable pattern, but which one?
--         if not skippable.closing_delimiter then
--           -- it's skippable till eol
--           break
--         end
--         -- it's a delimited skippable
--         inside_delimited_skippable = nearest_delimiter
--       else
--         -- it's a paren
--         -- normally this is where we would convert from byte idx to col, but it seems that
--         -- highlighting is using byte indexes instead of actual columns.
--         -- handle_paren(nearest_delimiter, line_nr, byte_idx_to_col(line_text, nearest_dilimiter_byte_idx_start))
--         handle_paren(nearest_delimiter, line_nr, nearest_dilimiter_byte_idx_start)
--       end
--       next_search_start_idx = nearest_dilimiter_byte_idx_end + 1
--     end
--   until false -- forever
-- end
-- vim.print('My rainbow parens done in: ' .. (os.clock() - t_begin) * 1000 .. ' ms')
-- vim.print('is_comment_or_string_time: ' .. is_comment_or_string_time * 1000 .. ' ms')
-- Measurements so far:
-- 1. just querying vim apis whether the parens are highlighted as comments, in a 800 lines ts tests file: 120ms
-- 2. manually parse each line to detect comments and strings: <20ms
-- 3. querying treesitter with
-- ["(" "[" "{"] @opener
-- then iterating the captures: 16 - 26 ms (this is with just coloring all parens blue)
-- 4. iterating each node manually with dfs: ~ 1 ms (sometimes 4ms on first call)

return M
