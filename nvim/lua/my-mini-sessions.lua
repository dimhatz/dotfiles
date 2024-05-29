local log_my_error = require('my-helpers').log_my_error
local path_delimiter = require('my-helpers').path_delimiter

local function save_cokeline_buffer_order()
  local ok_cokeline_buffers, buffers_lib = pcall(require, 'cokeline.buffers')
  if not ok_cokeline_buffers then
    log_my_error('My: cokeline.buffers not found. Not saving buffer order.')
    return
  end
  local valid_buffers = buffers_lib.get_valid_buffers()
  local file_paths = {}
  for _, buf in ipairs(valid_buffers) do
    table.insert(file_paths, buf.path)
  end
  local file_paths_json = vim.json.encode(file_paths)

  if string.find(file_paths_json, "'") then
    -- we will be appending a line like: let g:my_buf_order = '["path1", "path2"]'
    log_my_error("My: Found filename containing quote ('). Not saving buffer order.")
    return
  end

  local session_file = vim.v.this_session
  if vim.fn.filewritable(session_file) ~= 1 then
    log_my_error('My: No session file found. Not saving buffer order.')
    return
  end

  vim.fn.writefile({ '', "let g:my_buf_order = '" .. file_paths_json .. "'" }, session_file, 'as')
end

local function restore_cokeline_buffer_order()
  local ok_cokeline_buffers, buffers_lib = pcall(require, 'cokeline.buffers')
  if not ok_cokeline_buffers then
    vim.notify('My: cokeline.buffers not found. Not restoring buffer order.', vim.log.levels.WARN)
    return
  end
  local json = vim.g.my_buf_order
  if not json then
    vim.notify('My: my_buf_order global not found. Not restoring buffer order.', vim.log.levels.WARN)
    return
  end
  local file_paths = vim.json.decode(json)
  -- vim.print(file_paths)
  local offset = 0 -- if a buffer with a matching filename is not present, we move the subsequent buffers to a smaller target index
  for i, file_path in ipairs(file_paths) do
    local buffers = buffers_lib.get_valid_buffers() -- get the fresh list every time
    local buffer_found = false
    for _, buffer in ipairs(buffers) do
      if i <= #buffers and buffer.path == file_path then
        -- vim.print('moving ' .. file_path .. ' from ' .. buffer._valid_index .. ' to ' .. i)
        buffer_found = true
        -- BUG: move_buffer() does not always end up restoring correctly, not sure why
        buffers_lib.move_buffer(buffer, i - offset)
      end
    end
    if not buffer_found then
      vim.print('My: buffer not present: ' .. file_path .. ' not restoring its order')
      offset = offset + 1
    end
  end
  vim.opt.tabline = cokeline.tabline() -- force refresh, this is global cokeline
  vim.print('My: buffer order restored.')
end

local session_file = '.nvim_session'
local cwd_before_session_load = vim.fn.getcwd()
local session_file_path = cwd_before_session_load .. path_delimiter .. session_file

-- NOTE: we want to force the creation / writing of the session file to the directory where
-- nvim was started. On every start we create a dummy empty session file (if it does
-- not exist) in the starting directory and let mini.sessions pick it up.
-- This way, :cd command should not affect the session file location.
if vim.fn.filereadable(session_file) == 0 then
  vim.print('My: Creating new session file')
  vim.fn.writefile({ '' }, session_file, 's')
end

require('mini.sessions').setup({
  autoread = true,
  autowrite = true,
  file = session_file, -- local session file
  directory = '',
  hooks = {
    post = {
      write = save_cokeline_buffer_order,
      read = function()
        log_my_error('start logging', true)
      end,
    },
  },
})

vim.api.nvim_create_autocmd('UIEnter', {
  group = vim.api.nvim_create_augroup('my-session-init', {}),
  desc = 'write session file in cwd if not exists, restore cokeline buffer order',
  callback = function()
    -- triggers after VimEnter, but still needs timer, otherwise cokeline is not fully initialized and produces an error
    vim.fn.timer_start(0, restore_cokeline_buffer_order)

    local cwd_after_session_load = vim.fn.getcwd()
    if cwd_before_session_load ~= cwd_after_session_load then
      -- this should occur only if there is a 'cd' in the session file
      local msg = 'My: cwd changed after session load: ' .. cwd_before_session_load
      msg = msg .. ' -> ' .. cwd_after_session_load
      msg = msg .. '\nDid you :cd and forgot to :cd - to return? (before quitting previous session)'
      msg = msg .. '\nThe starting directory will still be used to store this session, not the current cwd'
      vim.notify(msg, vim.log.levels.ERROR)
    end

    local expected_session_path = session_file_path:gsub('\\', '/'):gsub('/+', '/')
    if expected_session_path ~= vim.v.this_session then
      -- mini.sessions uses '/' in paths, the above is from its code
      vim.print('My: expected session path: ' .. expected_session_path)
      vim.print('My: actual vim.v.this_session: ' .. vim.v.this_session)
      vim.notify('My: session file not picked up correctly', vim.log.levels.ERROR)
    else
      vim.print('My: session file picked up correctly')
    end
    -- vim.print('After entering UI. cwd: ' .. vim.fn.getcwd())

    -- if vim.fn.filereadable(session_file_path) ~= 0 then
    --   vim.print('My: Session found: ' .. session_file_path)
    --   return
    -- end
    -- require('mini.sessions').write(session_file_path, { force = false, verbose = true })
  end,
})

-- -- Without mini.sessions:
-- -- VimLeavePre to save session, VimEnter to load
-- -- BUG: even though mini.sessions uses the same autocmds, when we use the below instead of mini.sessions,
-- -- the lsp client is not attached to the first buffer that is restored (causing highlighting to be missing)
-- -- nvim -S .nvim_session works correctly, but is inconvenient to use
-- vim.api.nvim_create_autocmd('VimEnter', {
--   group = vim.api.nvim_create_augroup('my-autoload-session', {}),
--   desc = 'autoload session from file in cwd',
--   callback = function()
--     if vim.fn.filereadable(session_file_path_unescaped) ~= 0 then -- does not work when passing escaped path
--       vim.print('My: Session file found: ' .. session_file_path_unescaped)
--       vim.cmd('silent! %bwipeout!') -- Wipeout all buffers
--       vim.cmd('silent! source ' .. session_file_path)
--       log_my_error('start logging', true)
--     else
--       vim.print('My: Session file not found. A new one will be written before exiting, at path: ' .. session_file_path_unescaped)
--     end
--   end,
-- })
--
-- vim.api.nvim_create_autocmd('VimLeavePre', {
--   group = vim.api.nvim_create_augroup('my-autosave-session', {}),
--   desc = 'autosave session to directory from which vim was started',
--   callback = function()
--     vim.cmd('mksession! ' .. session_file_path)
--     save_cokeline_buffer_order()
--   end,
-- })
--
