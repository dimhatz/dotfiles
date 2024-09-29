local log_my_error = require('my-helpers').log_my_error
local path_delimiter = require('my-helpers').path_delimiter
local save_order_to_session = require('my-tabline').save_order_to_session
local restore_order_from_session = require('my-tabline').restore_order_from_session

local session_file_path = vim.fn.getcwd() .. path_delimiter .. 'Session.vim' -- nvim's default name

-- NOTE: using pure nvim sessions, not 'mini.sessions' anymore
-- NOTE: we want to force the creation / writing of the session file to the directory where
-- nvim was started. On every start we create a dummy empty session file (if it does
-- not exist) in the starting directory and then we pick it up.
-- This way, :cd command should not affect the session file location.
if vim.fn.filereadable(session_file_path) == 0 then
  vim.print('My: Creating new session file')
  vim.fn.writefile({ '' }, session_file_path, 's')
end

local mini_map = require('mini.map')

-- BUG: even though 'mini.sessions' uses the same autocmds, when we use the below without vim.schedule() or vim.fn.timer_start(),
-- the lsp client is not attached to the first buffer that is restored (causing highlighting to be missing etc)
-- nvim -S .nvim_session works correctly, but is inconvenient to use
vim.api.nvim_create_autocmd('UIEnter', {
  group = vim.api.nvim_create_augroup('my-autoload-session', {}),
  desc = 'autoload session from file in cwd',
  callback = function()
    vim.schedule(function()
      if vim.fn.filereadable(session_file_path) ~= 0 then -- does not work when passing escaped path
        vim.cmd('silent! %bwipeout!') -- Wipeout all buffers
        vim.cmd('silent! source ' .. session_file_path)
        log_my_error('start logging', true)
        restore_order_from_session()
        -- another wrap, otherwise text won't show up (something else must be clearing, but text is still accessible with :messages)
        vim.schedule_wrap(vim.print)('My: Session file found: ' .. session_file_path)
      else
        vim.notify('My: session file not found', vim.log.levels.ERROR)
      end

      if vim.v.this_session ~= session_file_path and vim.v.this_session ~= '' then
        vim.notify('My: session file not picked up correctly', vim.log.levels.ERROR)
        vim.print('Expected session file:', session_file_path)
        vim.print('Actual session file:', vim.v.this_session)
      end
      -- open mini.map here, so that it does not removed by session restoration script
      mini_map.open()
    end)
  end,
})

vim.api.nvim_create_autocmd('VimLeavePre', {
  group = vim.api.nvim_create_augroup('my-autosave-session', {}),
  desc = 'autosave session to directory from which vim was started',
  callback = function()
    -- closing mini.map here, to avoid nvim incorrectly saving the window sizes in session file
    -- see: https://github.com/echasnovski/mini.nvim/issues/851
    mini_map.close()
    vim.cmd('mksession! ' .. session_file_path)
    save_order_to_session()
  end,
})
