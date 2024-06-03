local log_my_error = require('my-helpers').log_my_error
local path_delimiter = require('my-helpers').path_delimiter
local save_order_to_session = require('my-tabline').save_order_to_session
local restore_order_from_session = require('my-tabline').restore_order_from_session

local session_file = '.nvim_session'
local session_file_path = vim.fn.getcwd() .. path_delimiter .. session_file

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
      write = save_order_to_session,
      read = function()
        log_my_error('start logging', true)
      end,
    },
  },
})

vim.api.nvim_create_autocmd('UIEnter', {
  group = vim.api.nvim_create_augroup('my-session-init', {}),
  desc = 'write session file in cwd if not exists, restore tabline buffer order',
  callback = function()
    -- cokeline needed a wrapper to delay execution
    -- vim.fn.timer_start(0, restore_order_from_session)
    -- vim.schedule(restore_order_from_session)
    restore_order_from_session()

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
