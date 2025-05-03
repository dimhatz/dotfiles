local remap = require('my-helpers').remap
local del_stack = {}

vim.api.nvim_create_autocmd('BufDelete', { -- before deleting buffer, also trigger on rename
  group = vim.api.nvim_create_augroup('my-save-buffer-name-to-undo-bdelete', {}),
  desc = 'Save buffer name to the undo bdel list (stack)',
  callback = function(arg)
    -- if the buffer is not unlisted, we push its path to del_stack
    -- vim.print('pre del')
    -- vim.print(arg)
    -- vim.print(del_stack)
    local bufnr = arg.buf
    -- local path2 = arg.match -- uses '/', does not escape spaces
    local path = vim.api.nvim_buf_get_name(bufnr) -- uses '\', does not escape spaces
    local is_listed = vim.api.nvim_get_option_value('buflisted', { buf = bufnr })

    if is_listed and #path > 0 then
      -- for some reason without #path > 0, when starting, 3 empty strings were pushed
      -- without any messages printed (this is likely during running session restore script)
      table.insert(del_stack, path)
    end
    -- vim.print(del_stack)
  end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
  group = vim.api.nvim_create_augroup('my-update-undo-bdelete-list', {}),
  desc = 'Save buffer name to the undo bdel list (stack)',
  callback = function(arg)
    -- if the buffer is not unlisted, we push its path to del_stack
    -- vim.print('post read')
    -- vim.print(arg)
    -- vim.print(del_stack)
    local bufnr = arg.buf
    -- local path2 = arg.match -- uses '/', does not escape spaces
    local path = vim.api.nvim_buf_get_name(bufnr) -- uses '\', does not escape spaces
    del_stack = vim.tbl_filter(function(val)
      return val ~= path and true or false
    end, del_stack)
    -- vim.print(del_stack)
  end,
})

remap('n', '<C-BS>', function()
  -- vim.print('restoring')
  -- vim.print(del_stack)
  if #del_stack < 1 then
    vim.notify('My: no more deleted buffers to restore.')
    return
  end

  local path = nil
  repeat
    path = del_stack[#del_stack]
    del_stack = vim.tbl_filter(function(val)
      return val ~= path and true or false
    end, del_stack)
  until (not path) or vim.fn.filereadable(path) ~= 0

  if not path then
    vim.notify('My: no valid buffers to restore.')
    return
  end

  vim.cmd.edit(path)

  vim.notify('My: restored ' .. path)
  -- vim.print(del_stack)
end, { desc = 'Undo close buffer' })
