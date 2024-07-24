local concat = require('my-helpers').safe_concat
local pad_spaces = require('my-helpers').pad_spaces

local function get_search_count()
  -- search results in page
  local padded_length = 7 ----->  >99/>99
  if vim.v.hlsearch == 0 then
    return pad_spaces('-----', padded_length)
  end
  -- can throw errors when called too often, with recompute = 0, does not show correct current
  local ok_s_count, s_count = pcall(vim.fn.searchcount, { recompute = 1 })
  local res = '  -----' -- 7 total length

  if ok_s_count and s_count.current ~= nil then
    local current = s_count.current
    local total = s_count.total
    local maxcount = s_count.maxcount
    if s_count.incomplete == 1 then -- timed out
      res = '  ?/?  '
    elseif s_count.incomplete == 2 then -- max count exceeded
      if total > maxcount and current > maxcount then
        res = ('>%d/>%d'):format(current, total)
      elseif total > maxcount then
        res = ('%d/>%d'):format(current, total)
      end
    else
      res = ('%d/%d'):format(current, total)
    end
  end
  return pad_spaces(res, padded_length)
end

MyStatusLineShowCalled = false
local called = 0

function My_update_statusline_active()
  local hi1 = '%#MyStatusLineSec1#' -- outermost part highlight (used on rightmost part)
  local hi2 = '%#MyStatusLineSec2#'
  local s = ''

  -- each of our items assumes there is already padding at its left and always
  -- leaves padding on its right

  local filetype = vim.bo.filetype
  if filetype == 'help' then
    s = concat(hi1, ' help', ' ')
    s = concat(s, hi2, ' %f%m%r')
    s = concat(s, '%=', hi1, get_search_count(), ' ')
    vim.wo.statusline = s
    return
  end

  -- cwd
  s = concat(s, hi1, ' ', vim.fn.fnamemodify(vim.fn.getcwd(), ':~'), ' ')

  -- filename
  local fname = vim.fn.expand('%:.')
  if vim.startswith(fname:lower(), 'c:') or vim.startswith(fname, '/') then
    -- when not inside current dir, try to show as relative to ~
    fname = vim.fn.fnamemodify(fname, ':~')
  end

  if fname == '' then
    fname = '[No Name]'
    if vim.bo.buftype ~= '' then
      fname = ('%s%s%s'):format('[', vim.bo.buftype, ']')
    end
  end

  local modified = vim.bo.modified
  if modified then
    -- • -- ● --
    s = concat(s, '%#MyStatusLineModified#', ' ', fname, ' ● ')
  else
    s = concat(s, hi2, ' ', fname)
  end

  -- separator, resetting color needed?
  s = concat(s, '%=')

  -- file warnings, only displayed when when needed
  s = concat(s, '%#MyStatusLineFileWarning#')
  local fenc = vim.bo.fileencoding
  if fenc ~= 'utf-8' and fenc ~= '' then
    -- empty fench will be saved as utf-8 by default, see :h :fenc
    s = concat(s, '[', fenc, '] ')
  end

  if vim.bo.fileformat ~= 'unix' then
    s = concat(s, '[', vim.bo.fileformat, '] ')
  end

  local readonly = (not vim.bo.modifiable) or vim.bo.readonly
  if readonly then
    s = concat(s, 'RO ')
  end

  if vim.bo.filetype == '' then
    s = concat(s, '[No ft] ')
  end

  -- local bufnr = vim.api.nvim_get_current_buf()
  -- lsp icon
  local has_lsp_attached = #vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() }) > 0

  if has_lsp_attached then
    s = concat(s, hi2, '  ')
  end

  -- diagnostic errors and warnings
  local diagnostics = vim.diagnostic.get()
  local errors = #vim.tbl_filter(function(v)
    return v.severity == vim.diagnostic.severity.ERROR
  end, diagnostics)
  local warnings = #diagnostics - errors -- show hits etc as warnings

  if errors > 0 then
    s = concat(s, '%#MyStatusLineLspError# E: ', errors, ' ')
  end

  if warnings > 0 then
    s = concat(s, '%#MyStatusLineLspWarning# W: ', warnings, ' ')
  end

  -- search count when searcing with /, will show: 1 / 123
  s = concat(s, hi1, ' ', get_search_count())

  -- virtual column (takes tabs as multiple spaces into account)
  s = concat(s, hi1, '%3v ') -- minwid 3 to prevent line shifting during movement

  if MyStatusLineShowCalled then
    called = called + 1 -- debugging
    s = concat(s, 'C: ', called)
  end

  vim.wo.statusline = s
end

function My_update_statusline_inactive()
  local s = ''
  vim.wo.statusline = concat(s, '%#StatusLineNC#', ' %f%m%r')
end

-- NOTE: using vim.schedule_wrap(), like mini.statusline
-- does. Their explanation:
-- Use `schedule_wrap()` to properly work inside autocommands because
-- they might temporarily change current window
-- Another alternative implementation would be to use cache and
-- assign the function to be evaluated in the statusline with '%{%v:lua.My()%}'
-- and only invalidate cache with autocmds
vim.api.nvim_create_autocmd({
  -- TODO: diagnostic autocmds
  'BufAdd',
  -- 'BufDelete',
  'BufEnter',
  'BufFilePost',
  -- 'BufLeave',
  'BufModifiedSet',
  'BufNew',
  'BufNewFile',
  'BufReadPost',
  'BufWinEnter',
  -- 'BufWipeout',
  'BufWritePost',
  'DiagnosticChanged',
  'DirChanged',
  'FileChangedRO',
  'FileChangedShellPost',
  -- 'FileReadPost', -- likely not needed
  'FileWritePost',
  'FocusGained',
  'LspAttach',
  'LspDetach',
  -- 'ModeChanged',
  -- 'OptionSet', -- WARN: do not use here, will mess up vim plugins
  'SessionLoadPost',
  'TabClosed',
  'TabEnter',
  'TabNew',
  'TabNewEntered',
  'TabClosed',
  'VimResume',
  'UIEnter',
  'VimResized',
  'WinEnter',
}, {
  desc = 'My: manually update active statusline',
  group = vim.api.nvim_create_augroup('my-update-active-statusline', {}),
  callback = vim.schedule_wrap(My_update_statusline_active),
  -- callback = My_update_statusline_active,
})

vim.api.nvim_create_autocmd({
  -- WARN: do not use a non-filtering OptionSet that triggers for every option,
  -- it will mess up vim plugins. The callback should not set the same option
  -- that has triggered it, see :h OptionSet
  'OptionSet',
}, {
  desc = 'My: manually update active statusline on some options set',
  group = vim.api.nvim_create_augroup('my-update-active-statusline-opt', {}),
  pattern = { 'hlsearch', 'readonly', 'modifiable', 'fileencoding', 'fileformat', 'filetype' },
  callback = vim.schedule_wrap(My_update_statusline_active),
  -- callback = My_update_statusline_active,
})

vim.api.nvim_create_autocmd({
  'WinLeave',
}, {
  desc = 'My: manually update inactive statusline',
  group = vim.api.nvim_create_augroup('my-update-inactive-statusline', {}),
  callback = My_update_statusline_inactive, -- do not schedule_wrap
})

-- TODO: when searching with /, does show results immediately, only after 'n'

-- -- benchmarks:
-- -- 0.02ms per active statusline render
-- -- 0.0035ms per inactive statusline render
-- -- 0.0026ms per static-string statusline render (empty string renders the default, with about
-- -- the same time)
-- vim.keymap.set('n', '<C-F11>', function()
--   local t_beg = os.clock()
--   local iterations = 100000
--   for _ = 1, iterations do
--     My_update_statusline_active()
--   end
--   local t_end = os.clock()
--   vim.print((t_end - t_beg) / iterations * 1000) -- ms
-- end)
--
-- vim.keymap.set('n', '<C-F9>', function()
--   local t_beg = os.clock()
--   local iterations = 100000
--   for _ = 1, iterations do
--     My_update_statusline_inactive()
--   end
--   local t_end = os.clock()
--   vim.print((t_end - t_beg) / iterations * 1000) -- ms
-- end)
--
-- vim.keymap.set('n', '<C-F8>', function()
--   local t_beg = os.clock()
--   local iterations = 100000
--   for _ = 1, iterations do
--     vim.wo.statusline = 'test123'
--   end
--   local t_end = os.clock()
--   vim.print((t_end - t_beg) / iterations * 1000) -- ms
-- end)
--

-- -- WARN: disable autocmds before running the belows to ensure statusline is not set from elsewhere
-- -- Test to see how often the statusline is evaluated, when set as a function
-- -- FINDINGS: called on every keystroke basically (in all modes), on some actions called >1 time
-- local called = 0
-- function My_print_calls()
--   called = called + 1
--   return 'called: ' .. called
-- end
-- vim.o.statusline = '%{%v:lua.My_print_calls()%}'
-- -- '%{%v:lua.MiniStatusline.active()%}'
