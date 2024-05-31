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

function M.log_my_error(str, overwrite)
  local path = vim.fn.stdpath('log') .. M.path_delimiter .. 'my.log'
  -- -- do not escape, not sure if needed, some funcs like filereadable() require unescaped paths,
  -- -- other things like :mksession require escaped paths
  -- path = vim.fn.fnameescape(path)
  vim.fn.writefile({ os.date() .. '   ' .. str }, path, overwrite and 's' or 'as')
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

return M
