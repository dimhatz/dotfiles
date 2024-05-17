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

function M.log_my_error(str, overwrite)
  local delimiter = vim.fn.has('win32') and '\\' or '/'
  local path = vim.fn.stdpath('log') .. delimiter .. 'my.log'
  vim.fn.writefile({ os.date() .. '   ' .. str }, path, overwrite and '' or 'a')
end

return M
