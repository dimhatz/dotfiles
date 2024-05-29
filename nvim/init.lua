-- for binaries on windows:
-- choco install -y ripgrep wget fd unzip gzip mingw make
-- NOTE: use :lua vim.diagnostic.setqflist() to all diagnostics into a quickfix list
if vim.g.neovide then
  -- -- from here: https://github.com/neovide/neovide/issues/2565
  -- keeps animations at minimum, while keeping smooth scrolling
  vim.g.neovide_position_animation_length = 0.0
  vim.g.neovide_cursor_animation_length = 0.00
  vim.g.neovide_cursor_trail_size = 0
  vim.g.neovide_cursor_animate_in_insert_mode = false
  vim.g.neovide_cursor_animate_command_line = false
  vim.g.neovide_scroll_animation_far_lines = 0.0
  vim.g.neovide_scroll_animation_length = 0.1 -- with 0 there are small jerks when scrolling, using 0.1

  -- vim.g.neovide_refresh_rate = 240 -- use when vsync = false in neovide, with 240 the scrolling is better than 60, gpu usage is x2, no latency reduction
  -- vim.g.neovide_cursor_animate_in_insert_mode = false -- not using, our cursor animations are at 0
  -- vim.g.neovide_scroll_animation_length = 0.1 -- only minimal scrolling animation, more smooth scrolling than 0
  -- vim.g.neovide_cursor_animate_command_line = false
  -- vim.g.neovide_cursor_animation_length = 0.00 -- no cursor animation

  -- WARN: do not set fonts for neovide here, but in {FOLDERID_RoamingAppData}/neovide/config.toml
  -- the below values are only for live testing fonts (not all configs are accessible from here)
  vim.opt.linespace = -1 -- for iosevka custom

  -- vim.g.neovide_no_idle = true
  -- TODO: check there can be more rendering options. letters looking too thin
  -- with Source Code Pro h10.5: 'd', 'u'. In comparison . In comparison 'i', 'l' look thicker, fuzzier.
  -- Also, antialiasing is stronger in alacritty
  -- skia's Graphite gpu backend does not yet support bgr: https://issues.chromium.org/issues/337905340
  -- in libreoffice they also use skia (maybe with older Ganesh gpu backend?)
  -- We could make a patch for neovide doing what libreoffice does.
  -- https://bugs.documentfoundation.org/show_bug.cgi?id=134275
  -- https://git.libreoffice.org/core/+/1171d609c52fc1f7cd58787e9ebc1ecca32fe450%5E%21
  -- vim.o.guifont = 'Source Code Pro:h10.5:#e-subpixelantialias:#h-none'
  -- vim.o.guifont = 'Source Code Pro:h11:#e-antialias:#h-none'

  -- vim.o.guifont = 'Source Code Pro:h11:#e-antialias:#h-full' -- GOOD2
  -- vim.opt.linespace = -1 -- for Source Code h11 only

  -- vim.o.guifont = 'Terminess Nerd Font:h12:#e-alias:#h-full'
  -- vim.o.guifont = 'Monaspace Krypton:h10.3:#e-alias:#h-full' -- kinda works too
  -- vim.o.guifont = 'Monaspace Krypton:h11:#e-antialias:#h-full'

  -- vim.o.guifont = 'FiraCode Nerd Font Mono:h11:#e-antialias:#h-full' -- GOOD, with h-none, 'i' gets the dot higher with no hinting, but with h-full, =, _ is clearer

  -- vim.o.guifont = 'FiraCode Nerd Font:h10.3:#e-antialias:#h-full' -- --> same size as Source Code Pro 10.5 h-full is cleaner for h10.3
  -- vim.opt.linespace = 1 -- 1 for FiraCode 10.3 only, to match overall font sizes of Source Code

  -- vim.o.guifont = 'Cascadia Mono NF SemiLight:h10.9:#e-antialias:#h-full' -- good, but did not like the 'm'
  -- vim.opt.linespace = 1 -- 1 for cascadia only, otherwise 'g' has clipped bottom
else
  vim.o.guifont = 'Source Code Pro:h10.5'
  -- vim.o.guifont = 'SauceCodePro NF:h10.5'
end

-- disable netrw, as required by nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.syntax = 'off' -- treesitter

--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed
vim.g.have_nerd_font = true
vim.opt.number = true
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  See `:help 'clipboard'`
vim.opt.clipboard = 'unnamedplus'

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- How often swap is written to disk (ms after nothing is typed),
-- also affects CursorHold, CursorHoldI, which we have mapped to
-- lsp-highlight word under cursor.
vim.opt.updatetime = 2000

-- Decrease mapped sequence wait time
-- Also controls which-key popup delay
vim.opt.timeoutlen = 1000

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
-- tab:│\ ,trail:•,extends:»,precedes:«,nbsp:■
-- trail = '·', trail = '•',
vim.opt.listchars = { tab = '│ ', trail = '•', nbsp = '■', extends = '»', precedes = '«' }
vim.opt.showbreak = '↪  ' -- can also use '▶ ', if not rendered

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- in command mode, first complete longest common, then cycle with tab, back cycle shift-tab
vim.opt.wildmode = 'list:longest,full'

-- do not open scratch buffer
-- vim.opt.completeopt = 'menuone,noselect' -- suggested by cmp plugin
vim.opt.completeopt = 'menu,menuone,noselect' -- removing noselect does not seem to make a difference

vim.opt.foldmethod = 'indent'
vim.opt.foldlevel = 999

-- Set highlight on search, will be cleared on <Esc> in normal
vim.opt.hlsearch = true

-- when searching, pressing n, will show "search hit BOTTOM, continuing at TOP"
-- also, disables showing search hit count on top of command line (we still have it in our statusline)
vim.opt.shortmess:append('S')

vim.o.termguicolors = true
vim.o.background = 'dark'

vim.o.sessionoptions = 'buffers,folds,tabpages,winpos,winsize,help'

-- TODO: always show gutter (signs)

-- -- another snippet (not tested)
-- local function close_floating()
--   for _, win in ipairs(vim.api.nvim_list_wins()) do
--     local config = vim.api.nvim_win_get_config(win)
--     if config.relative ~= '' then
--       vim.api.nvim_win_close(win, false)
--     end
--   end
-- end
--
--
-- -- works, but lengthy
-- local closeHoveringWindows = function()
--   local base_win_id = vim.api.nvim_get_current_win()
--   local windows = vim.api.nvim_tabpage_list_wins(0)
--   for _, win_id in ipairs(windows) do
--     if win_id ~= base_win_id then
--       local win_cfg = vim.api.nvim_win_get_config(win_id)
--       if win_cfg.relative == 'win' and win_cfg.win == base_win_id then
--         vim.api.nvim_win_close(win_id, false)
--         return
--       end
--     end
--   end
-- end
--
--------------------------------------------- KEYBINDINGS ----------------------------------------------------------------------

local closeHoveringWindows = function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative == 'win' then
      vim.api.nvim_win_close(win, false)
    end
  end
end

local onEsc = function()
  -- vim.cmd('nohlsearch') -- does not trigger mini.nvim's scrollbar highlight removal
  -- vim.api.nvim_exec2(':noh', {}) -- does not trigger mini.nvim's scrollbar highlight removal
  vim.api.nvim_exec2('set nohlsearch', {}) -- triggers correctly
  closeHoveringWindows() -- close the lsp hover windows
end

local remap = require('my-helpers').remap

remap('n', 'n', '<Cmd>set hlsearch<CR>n') -- trigger mini.nvim's scrollbar highlight
remap('n', 'N', '<Cmd>set hlsearch<CR>N')

remap('n', '<C-q>', '<Cmd>qa<CR>')
remap('n', '<Esc>', onEsc)
-- '/' is considered command mode
remap('c', '<Esc>', function()
  -- workaround to remove highlight from scrollbar, see onEsc()
  -- vim.cmd([[call feedkeys("\<Esc>", 'n')]]) -- jumps to next highlight, so we delete text manually
  -- <c-e><c-u> to delete all the text (:h c_CTRL-U), the following <bs> will auto-exit command mode
  vim.cmd([[call feedkeys("\<C-e>\<C-u>\<BS>", 'n')]]) -- works
  local cmd_type = vim.fn.getcmdtype()
  if cmd_type == '/' or cmd_type == '?' then
    vim.api.nvim_exec2('set nohlsearch', {})
  end
end)

remap('n', ';', ':')
remap('n', ':', ';')

remap('n', '<C-s>', '<Cmd>write<CR>')
remap('i', '<C-s>', '<Esc><Cmd>write<CR>')

-- To avoid operator pending delay, and the possibility to actually perform e.g. dw,
-- we perform operator remapping -> onore <expr>w v:operator == 'd' ? 'aw' : '<esc>'
-- NOTE: adding remap option { nowait = true } does not help, it is not what its puropose is.
-- NOTE2: this is not triggered by `v`
-- NOTE3: our remap of z becomes instant too (and e.g. `ze` triggers this func correctly)
local function my_w()
  -- dw -> daw, cw -> ciw, yw -> yiw
  if vim.v.operator == 'd' then
    return 'aw'
  elseif vim.v.operator == 'c' or vim.v.operator == 'y' then
    return 'iw'
  elseif vim.v.operator == 'g@' then -- custom operator, like with surround
    return 'w' -- return itself unchanged, do not return `iw`, since other plugins may be using custom operators too
  end
  vim.print(vim.v.operator)
  return '<Esc>'
end

local function my_z()
  -- dz -> dd, to make zz -> "_dd
  if vim.v.operator == 'd' then
    return 'd'
  end
  return '<Esc>'
end

remap('o', 'w', my_w, { expr = true })
remap('o', 'z', my_z, { expr = true })

remap('n', 'c', '"_c')
remap('n', 'C', '"_C')
remap('v', 'c', '"_c')
remap('n', 'x', '"_x', { desc = 'delete char into black hole' })
remap('n', 'z', '"_d', { desc = 'delete into black hole' })
remap('n', 'Z', '"_D', { desc = 'delete into black hole' })
remap('n', 'X', '<cmd>echo "use Z to delete into black hole till end of line"<CR>')
remap('v', 'x', '"_d')
remap('v', 'z', '"_d')

remap('n', 'j', 'gj') -- navigate wrapped lines
remap('n', 'k', 'gk')

remap('n', '<C-d>', '<C-w>c', { desc = 'Close (Delete) window' })
remap('n', '<C-c>', '<Cmd>bdelete<CR>', { desc = 'Fallback bdel (mini-bufremove should override)' }) -- will be overridden by mini-bufremove

remap('n', '<C-v>', 'V')
remap('n', 'V', '<C-v>')

remap('n', '<C-u>', 'gUiw') -- Uppercase word in norm/insert
remap('i', '<C-u>', '<Esc>gUiwea') -- FIXME: does not repeat

-- adjust hlsearch to work correctly with our manual flipping of it
remap('n', '<C-f>', '*<Cmd>set hlsearch<CR>', { desc = '<C-f> is the new *' })
remap('n', '*', '<cmd>echo "<C-f> is the new *"<CR>', { desc = '<C-f> is the new *' })
remap('n', '#', '#<Cmd>set hlsearch<CR>', { desc = '<C-f> is the new *' })
remap('n', '/', '<Cmd>set hlsearch<CR>/')
remap('n', '?', '<Cmd>set hlsearch<CR>?')

remap('i', '<C-v>', '<C-r>+', { desc = '<C-v> pastes in insert' })
remap('c', '<C-v>', '<C-r>+', { desc = '<C-v> pastes in command' })

-- " Reselect pasted text linewise, ( `[ is jump to beginning of changed/yanked )
remap('n', '<Leader>v', '`[V`]', { desc = 'Reselect pasted text linewise' })

remap('n', 'm', 'z', { desc = 'm is the new z (folds)' })

-- Just mapping to za is not enough, since the inner folds remain closed when toggling to open.
-- This happens because we use indent folding and when forcing foldlevel, the inner folds become closed too.
remap('n', 'mm', function()
  local line_nr = vim.fn.line('.')
  local is_fold_open = vim.fn.foldclosed(line_nr) == -1
  if is_fold_open then
    return 'zc' -- not zC, which closes everything possible at cursor
  end
  return 'zO'
end, { expr = true, desc = 'toggle fold recursively' })

-- remap('v', 'p', 'p:let @+=@0<CR>', { desc = 'Pasting in visual does not override the + register', silent = true }) -- original from my vimrc
remap('v', 'p', 'p:let @v=@+|let @+=@0<CR>', { desc = 'Pasting in visual stores the overwritten text in "v register', silent = true })
-- remap('v', 'p', 'p:let @v=@+<Bar>let @+=@0<CR>', { desc = 'Pasting in visual stores the overwritten text in "v register', silent = true }) -- also works

remap('n', '<C-h>', '<C-e>', { desc = 'Scroll down 1 line' })
remap('n', '<C-l>', '<C-y>', { desc = 'Scroll up 1 line' })
remap('v', '<C-h>', '<C-e>', { desc = 'Scroll down 1 line' })
remap('v', '<C-l>', '<C-y>', { desc = 'Scroll up 1 line' })
-- skipping insert, since we are using c-j / c-k to autocomplete in insert
-- remap('i', '<C-j>', '<C-o><C-e>', { desc = 'Scroll down 1 line' })
-- remap('i', '<C-k>', '<C-o><C-y>', { desc = 'Scroll up 1 line' })

-- sticks on folds, the cursor does not stay in the same spot
-- remap('n', '<C-j>', '1<C-d>', { desc = 'Scroll down 1 line with cursor steady' })
-- remap('n', '<C-k>', '1<C-u>', { desc = 'Scroll up 1 line with cursor steady' })

remap('n', '<C-j>', 'gj<C-e>', { desc = 'Scroll down 1 line with cursor steady' })
remap('n', '<C-k>', 'gk<C-y>', { desc = 'Scroll up 1 line with cursor steady' })
remap('v', '<C-j>', 'gj<C-e>', { desc = 'Scroll down 1 line with cursor steady' })
remap('v', '<C-k>', 'gk<C-y>', { desc = 'Scroll up 1 line with cursor steady' })

-- remap('n', '<A-j>', '1<C-d>', { desc = 'Scroll down 1 line with cursor steady' }) -- same as above, but with Alt, alacritty re-exposes (in flashes) the mouse if its inside terminal
-- remap('n', '<A-k>', '1<C-u>', { desc = 'Scroll up 1 line with cursor steady' })
remap('n', '<C-m>', 'M', { desc = 'Put cursor in the center of the screen, <CR> triggers <C-m> it too' })
remap('n', 'M', 'zz', { desc = 'Center the screen on the cursor' })

remap('n', '<C-z>', ':e!<CR>', { desc = 'Undo all changes since file last saved' })

remap('n', '<C-F1>', '<Cmd>setlocal foldlevel=1<CR>', { desc = 'Fold all text at level 1' })
remap('n', '<C-F2>', '<Cmd>setlocal foldlevel=2<CR>', { desc = 'Fold all text at level 2' })
remap('n', '<C-F3>', '<Cmd>setlocal foldlevel=3<CR>', { desc = 'Fold all text at level 3' })
remap('n', '<C-F4>', '<Cmd>setlocal foldlevel=4<CR>', { desc = 'Fold all text at level 4' })
remap('n', '<C-F5>', '<Cmd>setlocal foldlevel=5<CR>', { desc = 'Fold all text at level 5' })
remap('n', '<C-F6>', '<Cmd>setlocal foldlevel=6<CR>', { desc = 'Fold all text at level 6' })
remap('n', '<C-F7>', '<Cmd>setlocal foldlevel=7<CR>', { desc = 'Fold all text at level 7' })
remap('n', '<C-F10>', '<Cmd>setlocal foldlevel=999<CR>', { desc = 'Unfold all' })

-- now C-p and C-n autocomplete the beginning of the command and search.
remap('c', '<C-k>', '<Up>', { desc = 'Autocomplete in command mode' })
remap('c', '<C-j>', '<Down>', { desc = 'Autocomplete in command mode' })

remap('n', 'gt', '<Nop>', { desc = 'Not used, which-key still does not pick it up, or the following remaps' })
remap('n', 'gT', '<Nop>', { desc = 'Not used, which-key still does not pick it up, or the following remaps' })

-- <C-f> / # in visual search the selection, <Leader>f in normal/visual highlights word under cursor, but does not jump to it
-- currently, nvim has a remap, but cases that have e.g. backslash are not handled properly,
-- e.g. when selecting "\V" and pressing *, nvim will highlight the whole page
vim.api.nvim_exec2(
  [[
    function! g:MyVSetSearch(cmdtype)
      let temp = @s
      norm! gv"sy
      let @/ = '\V' . substitute(escape(@s, a:cmdtype.'\'), '\n', '\\n', 'g')
      let @s = temp
    endfunction

    xnoremap <silent><C-f> :<C-u>call g:MyVSetSearch('/')<CR>/<C-R>=@/<CR><CR>:<C-u>set hlsearch<CR>
    xnoremap <silent># :<C-u>call g:MyVSetSearch('?')<CR>?<C-R>=@/<CR><CR>:<C-u>set hlsearch<CR>
    nnoremap <silent><Leader>f viw:<C-u>call g:MyVSetSearch('/')<CR>:<C-u>set hlsearch<CR>
    xnoremap <silent><Leader>f :<C-u>call g:MyVSetSearch('/')<CR>:<C-u>set hlsearch<CR>
  ]],
  {}
)

-- TODO: check these out, adjust setup
-- -- Diagnostic keymaps
remap('n', 'ge', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror popup' })
-- remap('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
-- remap('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
-- remap('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- vim.diagnostic.config({
--   virtual_text = false,
--   float = {
--     header = false,
--     border = 'rounded',
--     focusable = true,
--   },
-- })
------------------------------------------------------- AUTOCOMMANDS --------------------------------------------------------------------------

--  See `:help lua-guide-autocommands`
vim.api.nvim_create_autocmd({ 'FileType' }, {
  desc = 'My: gd inside helpfiles jumps to links',
  group = vim.api.nvim_create_augroup('my-helpfile-jump', { clear = true }),
  pattern = { 'help' },
  callback = function(opts)
    remap('n', 'gd', '<C-]>', { silent = true, buffer = opts.buf, desc = 'Go to link inside helpfile' })
  end,
})

--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'My: Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('my-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank({ timeout = 300 })
  end,
})

-- Not using FileType, since it's assigned once (and trigger command), but not the following times when
-- the help buffer becomes hidden and revealed again. BufWinEnter is NOT triggered when nvim starts,
-- which is exactly what we want in case we manually resized help window. NOTE: it will still resize
-- the help window when opening another help file.
vim.api.nvim_create_autocmd({ 'BufWinEnter' }, {
  desc = 'My: helpfiles split only vertically',
  group = vim.api.nvim_create_augroup('my-helpfile-splits-vertically', { clear = true }),
  callback = function(arg)
    -- vim.print(arg)
    local buf_num = arg.buf
    local ft = vim.api.nvim_buf_get_option(buf_num, 'filetype') -- before v0.10
    -- local ft = vim.api.nvim_get_option_value('filetype', { buf = buf_num }) -- when fully switched to v0.10
    -- vim.print(ft)
    if ft == 'help' then
      vim.cmd.wincmd('L')
      vim.cmd('vertical resize 90')
    end
  end,
})

-- -- when restoring a session, correctly restore folds in inactive buffers
-- -- related: see above: vim.o.sessionoptions, vim.o.viewoptions
-- vim.api.nvim_create_autocmd('BufWinLeave', {
--   pattern = '.',
--   desc = 'My: Save window view to preserve folds in the buffer',
--   group = vim.api.nvim_create_augroup('my-save-window-view', { clear = true }),
--   callback = function()
--     vim.print('saving view')
--     -- for each buffer, a view file will be written in nvim-data/view
--     vim.cmd.mkview()
--   end,
-- })
--
-- vim.api.nvim_create_autocmd('BufWinEnter', {
--   pattern = '.',
--   desc = 'My: Restore window view to preserve folds in the buffer',
--   group = vim.api.nvim_create_augroup('my-restore-window-view', { clear = true }),
--   callback = function()
--     vim.print('restoring view')
--     vim.cmd.loadview()
--   end,
-- })
-- TODO: white this in lua
vim.api.nvim_exec2(
  [[
    set viewoptions-=options
    augroup my_remember_folds
      autocmd!
      autocmd BufWinLeave *.* if &ft !=# 'help' | mkview | endif
      autocmd BufWinEnter *.* if &ft !=# 'help' | silent! loadview | endif
    augroup END
  ]],
  {}
)

------------------------------------------------------- PLUGINS --------------------------------------------------------------------------------

-- Lazy.nvim bootstrap
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- NOTE: lazy runs init() during startup, before loading the plugin itself (after which config() runs).
require('lazy').setup({
  --------------------------------------------- COLORS -------------------------------------------------------------------------------------

  require('my-fix-auto-scroll'),

  require('my-base16'),

  require('my-colorizer'),

  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  require('my-nvim-tree'),

  require('my-cokeline'),

  require('my-hop'),

  require('my-whichkey'),

  require('my-indent-blankline'),

  require('my-rainbow-delimiters'),

  require('my-gitsigns'),

  require('my-todo-comments'),

  require('my-mini'),

  require('my-telescope'),

  require('my-treesitter'),

  require('my-conform'),

  require('my-lspconfig'), -- see inside for MasonInstall command

  require('my-none-ls'),

  require('my-typescript-tools'),

  require('my-cmp'),

  -- nvim-treesitter/nvim-treesitter-context, sticks surrounding function's signature to the top line
  {
    enabled = false,
    -- shows the surrounding function's signature (line) at the top line (if it was scrolled above), disabled for now until treesitter becomes fast
    'nvim-treesitter/nvim-treesitter-context',
  },
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

----------------  NOT USED ----------------------------------------------------------------
-- autoclose parens, quotes etc - does not expose its <CR> function that we need in our custom completion mapping, disabling
-- { 'm4xshen/autoclose.nvim', enabled = false, lazy = false, opts = { options = { disable_command_mode = true } } },

-- { 'lunarvim/darkplus.nvim' },

-- { 'folke/tokyonight.nvim' },

-- { 'rebelot/kanagawa.nvim' },

-------------------------------------------------------------------------------------------

-- vim: ts=2 sts=2 sw=2 et
