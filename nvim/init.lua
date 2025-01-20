local remap = require('my-helpers').remap
local update_treesitter_tree = require('my-helpers').update_treesitter_tree
local minimap_refresh_cmd = require('my-helpers').minimap_refresh_cmd

-- for binaries on windows:
-- choco install -y ripgrep wget fd unzip gzip mingw make
-- NOTE: use :lua vim.diagnostic.setqflist() to all diagnostics into a quickfix list
if vim.g.neovide then
  -- from here: https://neovide.dev/faq.html#how-to-turn-off-all-animations
  -- keeps animations at minimum, while keeping smooth scrolling
  vim.g.neovide_position_animation_length = 0.0
  vim.g.neovide_cursor_animation_length = 0.00
  vim.g.neovide_cursor_trail_size = 0
  vim.g.neovide_cursor_animate_in_insert_mode = false
  vim.g.neovide_cursor_animate_command_line = false
  vim.g.neovide_scroll_animation_far_lines = 0.0
  -- with 0 there are small jerks when scrolling
  -- with 0.1 scrolling is smooth buf when switching between buffers
  -- but there is a scroll animation when the buffer is full of text
  -- also search neovide_scroll_animation_length in my-tabline and my-telescope
  -- where we disable this to avoid scrolling when switching buffers and telescope-previewing
  vim.g.neovide_scroll_animation_length = 0.1

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

-- default values for cursor plus highlight group (neovide does not use)
vim.o.guicursor = 'n-v-c-sm:block-nCursor/nCursor,i-ci-ve:ver25-iCursor/iCursor,r-cr-o:hor20-iCursor/iCursor'

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

-- S: when searching, pressing n, will show "search hit BOTTOM, continuing at TOP"
-- also, disables showing search hit count on top of command line (we still have it in our statusline)
-- I: do not show the startup greeting
vim.opt.shortmess:append('SI')

vim.o.termguicolors = true
vim.o.background = 'dark'

vim.o.sessionoptions = 'buffers,folds,tabpages,winpos,winsize,help,sesdir'

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

-- global, to be available from vimscript
MyOnEsc = function()
  -- if we are in the middle of exchange, manually trigger
  -- the cancel exchange func, which is temporarily bound to <c-c> by
  -- mini.operators (currently no way to rebind)
  local exchangeMapArgs = vim.fn.maparg('<C-c>', 'n', false, true)
  if exchangeMapArgs.desc == 'Stop exchange' then
    exchangeMapArgs.callback()
    return
  end

  closeHoveringWindows() -- close the lsp hover windows

  -- NOT triggering :noh here!
  -- vim.cmd('nohlsearch') -- does not trigger mini.nvim's scrollbar highlight removal
  -- vim.api.nvim_exec2(':noh', {}) -- does not trigger mini.nvim's scrollbar highlight removal
  -- the following triggers removal, but when switching to another buffer, hlsearch is enabled again
  -- highlighting the word in other buffers
  -- vim.api.nvim_exec2('set nohlsearch', {})
  -- simulate_keys(':noh<CR>') -- works, but will leave ":noh" sign in command line, also bad practice
  -- vim.o.hlsearch = false -- also fails when switching between buffers (see above)
  -- The best way is to use :noh within the <Esc> mapping itself, with { silent = true }

  -- workaround for rainbow-delimiters, see explanation inside definition
  update_treesitter_tree()

  -- to remove the search count from statusline:
  vim.schedule(My_update_statusline_active)
end
remap('n', '<Esc>', '<Cmd>noh<CR><Cmd>lua MyOnEsc()<CR>' .. minimap_refresh_cmd, { silent = true })

-- search mode '/' is considered command mode
remap('c', '<Esc>', function()
  -- to remove the search count from statusline:
  vim.schedule(My_update_statusline_active)
  -- workaround to remove highlight from scrollbar, on <Esc> when searching with /, see also MyOnEsc()
  local cmd_type = vim.fn.getcmdtype()
  local is_search_mode = cmd_type == '/' or cmd_type == '?'
  -- NOTE: when we are in vim.ui.input(), e.g. in lsp rename, then: cmd_type == '@', in case we need it
  if is_search_mode then
    -- When <Esc> is mapped in command mode, e.g. cnoremap <Esc> <Esc>, then <Esc> acts like
    -- <CR>, see: https://github.com/neovim/neovim/issues/21585
    -- Additionally, when searching with / and using :cnore <Esc> <Esc>:noh<CR>,
    -- when pressing <Esc>, the cursor stays on the first search result
    -- location instead of jumping back to the original location.
    return '<C-c>:noh<CR>' -- works
    -- alternatively: <c-e><c-u> deletes all the text (:h c_CTRL-U), the following <BS>
    -- will auto-exit command mode. Side effect: the cmd text that we searched for will still be shown.
    -- vim.print('') -- workaround to remove cmd text
    -- return '<C-e><C-u><BS>:noh<CR>'
  else
    return '<C-c>'
  end
end, { expr = true, silent = true, desc = 'Remove highlight on esc when searching with /' })

remap({ 'n', 'x' }, ';', ':', { desc = 'Semicolon swapped with colon' })
remap({ 'n', 'x' }, ':', ';', { desc = 'Semicolon swapped with colon' })

remap('n', '<C-s>', function()
  vim.cmd.write()
  update_treesitter_tree()
end, { desc = 'Save file, update rainbow parens' })

remap(
  'i',
  '<C-s>',
  '<Esc><Cmd>write<CR><Cmd>lua require("my-helpers").update_treesitter_tree()<CR>',
  { desc = 'Esc to normal, save file, update rainbow parens' }
)

-- To avoid operator pending delay, and the possibility to actually perform e.g. dw,
-- we perform operator remapping -> onore <expr>w v:operator == 'd' ? 'aw' : '<esc>'
-- NOTE: adding remap option { nowait = true } does not help, it is not what its purpose is.
-- NOTE2: this is not triggered by `v`
-- NOTE3: our remap of z becomes instant too (and e.g. `ze` triggers this func correctly)
local function my_operator_w()
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

local function my_operator_z()
  -- dz -> dd, to make zz -> "_dd
  if vim.v.operator == 'd' then
    return 'd'
  end
  return '<Esc>'
end

remap('o', 'w', my_operator_w, { expr = true, desc = 'My special operator w' })
remap('o', 'z', my_operator_z, { expr = true, desc = 'My special operator z' })

_G.My_noop = function()
  -- Usage:
  -- vim.go.operatorfunc = 'v:lua.My_noop'
  -- vim.cmd('normal! g@l')
  -- vim.go.operatorfunc = 'v:lua.My_original_op' -- <-- now ready to be repeated, instead of
  -- repeating any 'normal! xyz' commands that may have been called in My_original_op
end

_G.My_dd = function()
  -- vim.v.operator here will always be g@, due to the way we call this
  local _, cursor_line = unpack(vim.fn.getcurpos())
  local line_text = vim.fn.getline(cursor_line)
  if line_text:match('^%s*$') then
    vim.cmd('normal! "_dd')
  else
    vim.cmd('normal! dd')
  end
  vim.go.operatorfunc = 'v:lua.My_noop'
  vim.cmd('normal! g@l')
  vim.go.operatorfunc = 'v:lua.My_dd'
  -- vim.cmd.normal({ args = { 'dd' }, bang = true })
end

remap('n', 'dd', function()
  -- not mapping operator pending mode (omap), it messes up our special visual repeat
  -- (e.g. on `ved`). Also using operatorfunc to make it repeatable
  vim.go.operatorfunc = 'v:lua.My_dd'
  return 'g@l'
end, { expr = true, desc = 'When dd-ing blank lines, do not overwrite the registers' })

---@param vim_move string
local function move_skipping_non_alphanum_chars(vim_move)
  -- we use this hack instead of modifying iskeyword option, because we want
  -- the original moves to be used with delete/yank/etc
  -- We send more of the provided vim moves until we either reach eol or there is a
  -- whitespace char on either left or right side of the cursor.
  local old_cursor_line, old_cursor_col
  local new_cursor_line, new_cursor_col
  local command = 'normal! ' .. vim_move

  while true do
    _, old_cursor_line, old_cursor_col = unpack(vim.fn.getcurpos()) -- 1-based, unlike vim.api.nvim_win_get_cursor()
    vim.cmd(command)
    _, new_cursor_line, new_cursor_col = unpack(vim.fn.getcurpos())

    -- in visual, cursor can get 1 char beyond line end
    if (new_cursor_line == old_cursor_line and new_cursor_col == old_cursor_col) or new_cursor_col == 1 or new_cursor_col >= vim.fn.col('$') - 1 then
      -- The cursor is on the same spot (very beginning or very end of buffer),
      -- or it's on beginning / eol.
      -- vim.fn.col('$') returns 1-based position of last char in current line + 1 (one beyond last char)
      return
    end

    local line_text = vim.fn.getline(new_cursor_line)
    local char_under_cursor = line_text:sub(new_cursor_col, new_cursor_col)

    -- always wrap it in a set [] or complement of set [^], see also :h lua-patterns.
    -- Not using %p for punctuation since we cannot exclude chars like _,&,!,$ from it (we
    -- need to able to jump to word that/begins ends with _,&,! etc)
    local punctuation_char_pattern = '%,%.%:%;%(%)%[%]%{%}%<%>%`%\'%"%|'

    if #char_under_cursor ~= 1 or char_under_cursor:match('[^' .. punctuation_char_pattern .. ']') then
      -- the cursor is beyond eol or on a non-punctuation char,
      return
    end

    -- at this point our char is definitely a punctuation char
    -- test (e) 'e' "z" |z| .z. ('z') '"(x)"' (((x))) ''x'' .. text

    -- stop when encountering a cluster of punctuations, surrounded by whitespace
    if (vim_move == 'w' or vim_move == 'b') and line_text:sub(new_cursor_col - 1):match('^%s[' .. punctuation_char_pattern .. ']*%s') then
      return
    end

    if vim_move == 'e' and line_text:sub(1, new_cursor_col + 1):match('%s[' .. punctuation_char_pattern .. ']*%s$') then
      return
    end

    -- if the remaining chars till eol are all whitespaces and punctuation, keep the default w,e behavior
    if (vim_move == 'w' or vim_move == 'e') and line_text:sub(new_cursor_col):match('^[%s' .. punctuation_char_pattern .. ']*$') then
      return
    end

    -- same for 'b' and the remaining previous chars
    if vim_move == 'b' and line_text:sub(1, new_cursor_col):match('^[%s' .. punctuation_char_pattern .. ']*$') then
      return
    end
  end
end

remap({ 'n', 'v' }, 'w', function()
  -- Benchmarked: 0ms most of the time, some occasional 1ms time.
  -- local t_begin = os.clock()
  move_skipping_non_alphanum_chars('w')
  -- vim.print((os.clock() - t_begin) * 1000) -- ms
end, { desc = 'My w skips non-alphanum chars, when they are not surrounded by whitespace' })

remap({ 'n', 'v' }, 'e', function()
  move_skipping_non_alphanum_chars('e')
end, { desc = 'My e skips non-alphanum chars, when they are not surrounded by whitespace' })

remap({ 'n', 'v' }, 'b', function()
  move_skipping_non_alphanum_chars('b')
end, { desc = 'My b skips non-alphanum chars, when they are not surrounded by whitespace' })

remap({ 'n', 'v' }, 'c', '"_c')
remap('n', 'C', '"_C')
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

remap('n', '<C-u>', 'gUiw', { desc = 'Uppercase word under cursor' }) -- Uppercase word in norm/insert
remap('i', '<C-u>', '<Esc>gUiwea', { desc = 'Uppercase word under cursor' }) -- FIXME: does not repeat

-- adjust hlsearch to work correctly with mini.nvim's scrollbar highlight
remap('n', '*', '*<Cmd>set hlsearch<CR>', { desc = 'vanilla *, with workaround for highlighting' })
remap('n', '#', '#<Cmd>set hlsearch<CR>', { desc = 'vanilla #, with workaround for highlighting' })
remap('n', '/', '<Cmd>set hlsearch<CR>/')
remap('n', '?', '<Cmd>set hlsearch<CR>?')
remap('n', 'n', '<Cmd>set hlsearch<CR>n')
remap('n', 'N', '<Cmd>set hlsearch<CR>N')

remap('n', '<C-q>', '<Cmd>qa<CR>', { desc = 'Quit vim' })

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

remap('v', 'p', 'p<Cmd>let @p=@+<Bar>let @+=@0<CR>', { desc = 'Pasting in visual stores the overwritten text in "p register', silent = true })

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

remap('n', '<C-z>', function()
  -- WORKAROUND: if we don't save and restore window the cursor jumps to the location
  -- where the cursor was on initial file open
  local win_view = vim.fn.winsaveview()
  vim.cmd('e!')
  vim.fn.winrestview(win_view)
end, { desc = 'Undo all changes since file last saved' })

remap('n', '<F1>', '<Cmd>setlocal foldlevel=1<CR>', { desc = 'Fold all text at level 1' })
remap('n', '<F2>', '<Cmd>setlocal foldlevel=2<CR>', { desc = 'Fold all text at level 2' })
remap('n', '<F3>', '<Cmd>setlocal foldlevel=3<CR>', { desc = 'Fold all text at level 3' })
remap('n', '<F4>', '<Cmd>setlocal foldlevel=4<CR>', { desc = 'Fold all text at level 4' })
remap('n', '<F5>', '<Cmd>setlocal foldlevel=5<CR>', { desc = 'Fold all text at level 5' })
remap('n', '<F6>', '<Cmd>setlocal foldlevel=6<CR>', { desc = 'Fold all text at level 6' })
remap('n', '<F7>', '<Cmd>setlocal foldlevel=7<CR>', { desc = 'Fold all text at level 7' })
remap('n', '<F10>', '<Cmd>setlocal foldlevel=0<CR>', { desc = 'Fold all text at level 0' })
remap('n', '<F11>', '<Cmd>setlocal foldlevel=999<CR>', { desc = 'Unfold all' })
remap('n', '<F12>', '<Cmd>setlocal foldlevel=999<CR>', { desc = 'Unfold all' })

-- now C-p and C-n autocomplete the beginning of the command and search.
remap('c', '<C-k>', '<Up>', { desc = 'Autocomplete in command mode' })
remap('c', '<C-j>', '<Down>', { desc = 'Autocomplete in command mode' })

-- <Esc>A, <C-o>A -> required 1 undo
-- <C-o>$, <End>,  also work, requires 2 undos
-- Dot (.) does not repeat both edits in all cases, not sure whether triggers mode change
remap('i', '<C-e>', '<Esc>A', { desc = 'Jump to EOL' })
remap({ 'n', 'v' }, '<C-e>', '$', { desc = 'Jump to EOL' })

-- Stop reaching too far with fingers for =, +, -, _
remap({ 'i', 'c' }, '<C-f>', '=', { desc = '<C-f> is = in insert' })
remap({ 'i', 'c' }, '<C-g>', '+', { desc = '<C-g> is + in insert' })
remap({ 'i', 'c' }, '<C-d>', '_', { desc = '<C-d> is _ in insert' })
remap({ 'i', 'c' }, '<C-a>', '-', { desc = '<C-a> is - in insert' })

-- avoid conflict with our <c-f> which is = in insert and cmd modes
remap('c', '<C-z>', '<C-f>', { desc = 'Open window with all previous commands' })

-- see https://stackoverflow.com/questions/24983372/what-does-ctrlspace-do-in-vim
remap({ 'i' }, '<C-Space>', '<Space>', { desc = 'Workaround, <C-space> can be ambiguously interpreted as <C-@>' })

-- When doing :nnore r<C-f> r=
-- and the timeout passes, the mapping will not activate. Workaround:
remap('n', 'r', function()
  -- change and restore cursor, otherwise it stays the same
  local orig_cursor = vim.o.guicursor
  vim.o.guicursor = 'a:hor20-iCursor/iCursor'
  local c = vim.fn.getcharstr()
  vim.o.guicursor = orig_cursor
  -- NOTE: the below string literals need to be entered with <c-v> in insert (after :iunmap <c-v>)
  -- since these are special vim's internal escape codes.
  if c == '' then
    return 'r='
  elseif c == '' then
    return 'r+'
  elseif c == '' then
    return 'r_'
  elseif c == '' then
    return 'r-'
  end
  return 'r' .. c
end, { expr = true, desc = 'replace single char, supports our special insert keymaps (<C-d> etc)' })

local function my_set_search()
  -- no type = 'v', since it will stop at the cursor
  local selected_strings = vim.fn.getregion(vim.fn.getpos('v'), vim.fn.getpos('.'), { type = vim.fn.mode() })
  if #selected_strings == 0 then
    -- invalid selection
    return false
  end
  selected_strings = vim.tbl_map(function(str)
    -- not using '\/.*$^~[]' because we will be using verynomagic \V search
    return vim.fn.escape(str, '/\\')
  end, selected_strings)
  local search_string = table.concat(selected_strings, '\\n')
  vim.fn.setreg('/', '\\V' .. search_string)
end

remap('v', '<C-f>', function()
  my_set_search()
  return '<Esc><Cmd>set hlsearch<CR>'
end, { expr = true, desc = 'Search for selection' })

remap('n', '<C-f>', function()
  -- also use mark `v` to jump back, when search is set
  vim.cmd('normal! mvviw')
  my_set_search()
  vim.cmd.execute([["normal! \<Esc>\<Cmd>set hlsearch\<CR>`v"]])
end, { desc = 'Search for word under cursor' })

remap({ 'n', 'v' }, '<Leader>f', '<Cmd>echo "use <C-f> (or * to search+jump)"<CR>', { desc = 'Use <C-f> (or * to search+jump)' })

-- TODO: check these out, adjust setup
-- -- Diagnostic keymaps
remap('n', 'ge', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror popup' })
-- remap('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
-- remap('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
-- remap('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

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

remap('n', 'o', function()
  -- Workaround: By default, when pressing "o" from an area that has comments,
  -- the new line starts already commented, even if its the last commented line.
  -- We want 'o' to produce auto-commented line only when deep inside comments.
  -- Alternatively (will remove comment auto-prefixing):
  -- vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  --   desc = 'My: Do not autocomment new line with "o" / "O"',
  --   group = vim.api.nvim_create_augroup('my-no-comments-on-o', { clear = true }),
  --   callback = function()
  --     vim.opt.formatoptions:remove('o')
  --     vim.opt_local.formatoptions:remove('o')
  --   end,
  -- })
  local line = vim.fn.line('.')
  -- indent should be correct even if e.g. 3 spaces lead the line, if there are intermixed tabs etc
  -- + 1 is needed since the columns start at 1, not 0
  local first_non_blank_col = vim.fn.indent(line) + 1
  -- check syntax group of the first non-blank char, following any links
  local synID = vim.fn.synID(line, first_non_blank_col, 0)
  local hl_name = vim.fn.synIDattr(synID, 'name')
  local line_is_comment = hl_name == 'Comment' or hl_name:lower():find('comment') ~= nil

  -- alternatively, we can follow hl links and check if the final hl is "comment"
  -- local synID = vim.fn.synIDtrans(vim.fn.synID(line, first_non_blank_col, 0))
  -- local line_is_comment = hl_name == 'Comment' or hl_name:lower():find('comment') ~= nil
  -- vim.print(hl_name .. ' ' .. tostring(line_is_comment))

  local line_is_last = vim.fn.line('.') == vim.fn.line('$')
  if line_is_comment and not line_is_last then
    return 'jO'
  else
    return 'o'
  end
end, { expr = true, desc = 'Make new line (after comment) start non-commented.' })

-- hack to prevent the cursor from jumping after a yank, also see below 'TextYankPost'
remap({ 'n', 'v' }, 'y', 'myy', { desc = 'Set mark "y" before yanking' })
remap('n', 'Y', 'myy$', { desc = 'Set mark "y" before yanking (workaround to keep cursor from moving)' })
remap('v', 'Y', '<Nop>', { desc = 'Not using visual Y anyway' })
-- see my TextYankPost autocmd, this one is to cleanup for yank
-- was interrupted by <esc> (operator pending mode)
-- remap('o', '<Esc>', '<Cmd>delmarks y<CR><Esc>') -- also works, but will be applied for all operators
remap('n', 'y<Esc>', '<Esc><Cmd>delmarks y<CR><Cmd>echom "ok"<CR>', { desc = 'Avoid leaving y mark with y<Esc>' })

--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'My: Highlight when yanking and put cursor back afterwards',
  group = vim.api.nvim_create_augroup('my-highlight-yank', { clear = true }),
  callback = function()
    if vim.v.operator ~= 'y' then
      -- avoid triggering on delete operator
      -- no need to check for operator == 'Y', it already triggers
      return
    end
    local y_mark_pos = vim.api.nvim_buf_get_mark(0, 'y') -- 1,0-based
    if y_mark_pos[1] == 0 and y_mark_pos[2] == 0 then
      -- defensive, non-existent mark
      return
    end
    -- vim.cmd('norm! `y') -- <-- do not use, messes up our visual repeat, does not fire ModeChanged
    vim.api.nvim_win_set_cursor(0, y_mark_pos)
    vim.cmd.delmarks('y') -- cleanup, unnecessary since we dont use 'y mark
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
    -- local ft = vim.api.nvim_buf_get_option(buf_num, 'filetype') -- before v0.10
    local ft = vim.api.nvim_get_option_value('filetype', { buf = buf_num }) -- when fully switched to v0.10
    -- vim.print(ft)
    if ft == 'help' then
      vim.cmd.wincmd('L')
      vim.cmd('vertical resize 90')
    end
  end,
})

-- TODO: delete this when the below lua version is confirmed to work
-- This also prevents scroll-to-center-cursor behavior of default vim, when switching between buffers
-- vim.cmd([[
--      set viewoptions-=options
--      augroup my_remember_folds
--        autocmd!
--        autocmd BufWinLeave *.* if &ft !=# 'help' | mkview | endif
--        autocmd BufWinEnter *.* if &ft !=# 'help' | silent! loadview | endif
--      augroup END
--    ]])

-- This also prevents scroll-to-center-cursor behavior of default vim, when switching between buffers
local save_load_view_group = vim.api.nvim_create_augroup('my-save-load-view', { clear = true })
vim.api.nvim_create_autocmd({ 'BufWinEnter' }, {
  desc = 'My: Restore file view (folds, also to avoid scroll to middle default behavior)',
  group = save_load_view_group,
  callback = function()
    if vim.bo.filetype == 'help' and vim.bo.buftype ~= '' then
      return
    end
    vim.cmd.loadview({ mods = { emsg_silent = true } }) -- do now show error messages
  end,
})

vim.api.nvim_create_autocmd({ 'BufWinLeave' }, {
  desc = 'My: Save file view (folds, also to restore and avoid scroll to middle default behavior)',
  group = save_load_view_group,
  callback = function()
    if vim.bo.filetype == 'help' and vim.bo.buftype ~= '' then
      return
    end
    -- for each buffer, a view file will be written in nvim-data/view
    vim.cmd.mkview({ mods = { emsg_silent = true } }) -- do now show error messages
  end,
})

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
  -- require('my-profile'),

  require('my-base16'),

  require('my-colorizer'),

  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  require('my-nvim-tree'),

  require('my-whichkey'),

  -- adds input lag, not using this
  -- require('my-indent-blankline'),

  -- TODO: try disabling treesitter (and rainbow-delimiters?) on .ts files, measure input lag,
  -- also, try opening a few .ts files (lage ones), after switching between them,
  -- there seem to be some spikes. Commands: TSDisable highlight, syntax on

  -- for non-treesitter rainbow (vimscript): luochen1990/rainbow, but does not work out of the
  -- box with neovim, see their github issue: https://github.com/luochen1990/rainbow/issues/163
  -- NOTE: rainbow-delimiters works without treesitter highlighting (with TS just being enabled)
  -- likely with less lag than with TS highlighting
  require('my-rainbow-delimiters'),

  require('my-gitsigns'),

  require('my-todo-comments'),

  require('my-mini'),

  require('my-trouble'),
  -- TODO: learn how to use with quickfix list, e.g.
  -- https://www.integralist.co.uk/posts/vim/#filtering-quickfix-and-location-list-results
  require('my-telescope'),

  require('my-treesitter'),

  require('my-conform'),

  require('my-lspconfig'), -- see inside for MasonInstall command

  require('my-none-ls'),

  require('my-typescript-tools'),

  -- require('my-rustaceanvim'), -- only use after removing our lspconfig entry

  require('my-cmp'),

  -- it is loaded, but earlier than the bundled syntax file
  -- :filter syntax scriptnames
  -- :scriptnames
  -- most likely it works since the syntax file itself contains early exit when b:current_syntax is set
  -- if syntax highlighting becomes off (never seen so far):
  -- :syn sync fromstart
  { 'HerringtonDarkholme/yats.vim' },

  -- nvim-treesitter/nvim-treesitter-context, sticks surrounding function's signature to the top line
  -- {
  --   enabled = false,
  --   -- shows the surrounding function's signature (line) at the top line (if it was scrolled above), disabled for now until treesitter becomes fast
  --   'nvim-treesitter/nvim-treesitter-context',
  -- },
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '[cmd]',
      config = '[conf]',
      event = '[ev]',
      ft = '[ft]',
      init = '[init]',
      import = '[import]',
      keys = '[keys]',
      lazy = '[lazy]',
      loaded = '[loaded]',
      not_loaded = '[not_loaded]',
      plugin = '[plugin]',
      runtime = '[runtime]',
      require = '[require]',
      source = '[source]',
      start = '[start]',
      task = '[task]',
      list = {
        '-',
        '->',
        '-->',
        '--->',
      },
    },
  },
})

require('my-statusline')
require('my-tabline')
require('my-hop3')
require('my-visual-repeat')
----------------  NOT USED ----------------------------------------------------------------
-- autoclose parens, quotes etc - does not expose its <CR> function that we need in our custom completion mapping, disabling
-- { 'm4xshen/autoclose.nvim', enabled = false, lazy = false, opts = { options = { disable_command_mode = true } } },

-- { 'lunarvim/darkplus.nvim' },

-- { 'folke/tokyonight.nvim' },

-- { 'rebelot/kanagawa.nvim' },

-------------------------------------------------------------------------------------------

-- vim: ts=2 sts=2 sw=2 et
