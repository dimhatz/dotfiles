local M = {}

-- mark all my remappings with (My) to be able to tell which mappings are mine, which are by plugins
function M.remap(mode, lhs, rhs, opts)
  local final_opts = opts or {}
  local desc = final_opts.desc or ''
  final_opts.desc = desc .. ' (My)'
  vim.keymap.set(mode, lhs, rhs, final_opts)
end

return M
