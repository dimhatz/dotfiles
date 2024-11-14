-- NOTE: this is already handled by our my_remember_folds (search configs globally for this augroup)
--
-- prevent scrolling (centering the cursorline) when changing buffers
-- return {
--   'BranimirE/fix-auto-scroll.nvim',
--   -- lua port of https://vim.fandom.com/wiki/Avoid_scrolling_when_switch_buffers
--   -- TODO: find workaround for viewport being positioned in the center,:h getwininfo(), :h line(), :h winsaveview(), -> vim.fn
--   -- post workaround: https://github.com/neovim/neovim/issues/9179
--   config = true,
--   event = 'VeryLazy',
-- }

-- The below is stolen from: BranimirE/fix-auto-scroll.nvim, as of commit c211a42f4030c9ed03a1456919917cdf1a193bd9,
-- copied here to avoid extra dep and potential security issue due to using a low-start repo/plugin.
-- lua port of https://vim.fandom.com/wiki/Avoid_scrolling_when_switch_buffers
-- TODO: find workaround for viewport being positioned in the center,:h getwininfo(), :h line(), :h winsaveview(), -> vim.fn
-- post workaround: https://github.com/neovim/neovim/issues/9179

local M1 = {
  SESSION = {
    saved_buff_view = {},
  },
}

-- Code based on: https://vim.fandom.com/wiki/Avoid_scrolling_when_switch_buffers#:~:text=When%20switching%20buffers%20using%20the,line%20relative%20to%20the%20screen.

function M1.save_win_view()
  local win_id = vim.fn.win_getid()
  if not M1.SESSION.saved_buff_view[win_id] then
    M1.SESSION.saved_buff_view[win_id] = {}
  end
  M1.SESSION.saved_buff_view[win_id][vim.fn.bufnr('%')] = vim.fn.winsaveview()
  -- M1.log('Saving win view')
end

function M1.restore_win_view()
  local buf = vim.fn.bufnr('%')
  local win_id = vim.fn.win_getid()
  if M1.SESSION.saved_buff_view[win_id] and M1.SESSION.saved_buff_view[win_id][buf] then
    local v = vim.fn.winsaveview()
    if v.lnum == 1 and v.col == 0 and not vim.api.nvim_get_option_value('diff', {}) then
      vim.fn.winrestview(M1.SESSION.saved_buff_view[win_id][buf])
    end
    -- M1.log('Restoring win view ' .. buf)
    M1.SESSION.saved_buff_view[win_id][buf] = nil
  end
end

local utils = M1
local M = {}

function M.setup(opts)
  local AutoSaveViewGroup = vim.api.nvim_create_augroup('AutoSaveViewGroup', {})
  vim.api.nvim_create_autocmd('BufEnter', {
    group = AutoSaveViewGroup,
    pattern = '*',
    callback = function()
      utils.restore_win_view()
    end,
  })
  vim.api.nvim_create_autocmd('BufLeave', {
    group = AutoSaveViewGroup,
    pattern = '*',
    callback = function()
      utils.save_win_view()
    end,
  })
end

-- M.setup()

-- return M
