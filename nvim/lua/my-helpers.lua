local M = {}

-- mark all my remappings with (My) to be able to tell which mappings are mine, which are by plugins
function M.remap(mode, lhs, rhs, opts)
  local final_opts = opts or {}
  local desc = final_opts.desc or ''
  final_opts.desc = desc .. ' (My)'
  vim.keymap.set(mode, lhs, rhs, final_opts)
end

-- returns a wrapper function that calls callback with the provided params
function M.make_wrapper_fn(callback, ...)
  local args = { ... }
  return function()
    callback(unpack(args))
  end
end

M.path_delimiter = vim.fn.has('win32') and '\\' or '/'

function M.log_my_error(err, overwrite)
  local path = vim.fn.stdpath('log') .. M.path_delimiter .. 'my.log'
  -- -- do not escape, not sure if needed, some funcs like filereadable() require unescaped paths,
  -- -- other things like :mksession require escaped paths
  -- path = vim.fn.fnameescape(path)
  vim.fn.writefile({ os.date() .. '   ' .. vim.inspect(err) }, path, overwrite and 's' or 'as')
end

---If possible, returns the first key of dict that has value == needle.
---Returns nil otherwise.
function M.find_key(dict, needle)
  for key, value in pairs(dict) do
    if value == needle then
      return key
    end
  end
  return nil
end

---If possible, returns the first key of dict that has pred(value) == true
---Returns nil otherwise.
function M.find_key_pred(dict, pred)
  for key, value in pairs(dict) do
    if pred(value) == true then
      return key
    end
  end
  return nil
end

---Safely concat any amounts of arguments. Those that are not strings or numbers
---are ignored.
function M.safe_concat(...)
  local args = { ... }
  args = vim.tbl_filter(function(v)
    return type(v) == 'string' or type(v) == 'number'
  end, args)
  return table.concat(args)
end

local pad_left = true

---pad spaces on both sized, starting with left, until the length of resulting string is == num
function M.pad_spaces(str, num)
  if #str >= num then
    return str
  end

  local res = str
  repeat
    if pad_left then
      res = ' ' .. res
    else
      res = res .. ' '
    end
    pad_left = not pad_left
  until #res >= num
  pad_left = true -- reset
  return res
end

-- On windows paths are messed up, forward/backward slashes are often intermixed,
-- Sometimes drive letter (e.g. C:) is capitalized, sometimes not. In session files,
-- '\' are converted to '/', but drive name can be either upper/lower.
---like vim.fs.normalize() but always capitalizes "c:" on windows
function M.normalize_filename(fname)
  local res = vim.fs.normalize(fname)
  local sub23 = res:sub(2, 3)
  if vim.fn.has('win32') and (sub23 == ':' or sub23 == ':\\' or sub23 == ':/') then
    return ('%s%s'):format(res:sub(1, 1):upper(), res:sub(2, -1))
  end
  return res
end

--- Simulates @param keys (string) interpreted as key presses,
--- sequences like <Esc>, <CR>, <C-c> will have the same result as
--- pressing the actual <Esc>, <CR>, <C-c>. No remapping is
--- performed during execution.
function M.simulate_keys(keys)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), 'n', false)
  -- Notes from previous experiments
  -- vim.fn.feedkeys('\\<Esc>', 'n') -- does not work to send <esc>
  -- vim.cmd([[call feedkeys("\<Esc>", 'n')]]) -- works
end

--- Workaround for rainbow-delimiters: calling this will update the color parens, even with
--- treesitter highlight disabled.
function M.update_treesitter_tree()
  -- TODO: remove this if we are using treesitter for highlighting
  -- This is a workaround for the rainbow-delimiters, which will only hightlight
  -- the currently parsed tree's parens. When adding new code with parens they will
  -- not be hightlighted.
  local ok_parser, parser = pcall(vim.treesitter.get_parser)
  if not ok_parser or not parser then
    return
  end
  parser:parse()
end

function M.reverse_in_place(arr)
  local i, j = 1, #arr
  while i < j do
    arr[i], arr[j] = arr[j], arr[i]
    i = i + 1
    j = j - 1
  end
end

return M
