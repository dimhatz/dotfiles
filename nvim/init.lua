-- for binaries on windows:
-- choco install -y ripgrep wget fd unzip gzip mingw make
-- NOTE: use :lua vim.diagnostic.setqflist() to all diagnostics into a quickfix list
if vim.g.neovide then
  vim.g.neovide_refresh_rate = 60
  vim.g.neovide_cursor_animate_in_insert_mode = false
  -- vim.g.neovide_no_idle = true
  -- TODO: set options for subpixel rendering
end

vim.opt.syntax = 'off' -- treesitter

vim.o.guifont = 'Source Code Pro:h10.5'

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

-- How often swap is written to disk (ms after nothing is typed)
vim.opt.updatetime = 4000

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 500

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

vim.o.sessionoptions = 'buffers,curdir,folds,tabpages,winpos,winsize,help,globals' -- globals needed by barbar to restore tab positions (with autocmds)

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
  vim.cmd('nohlsearch')
  closeHoveringWindows() -- close the lsp hover windows
end

-- returns a wrapper function that calls callback with the provided params
local function make_wrapper_fn(callback, ...)
  local args = { ... }
  return function()
    callback(unpack(args))
  end
end

-- mark all my remappings with (My) to be able to tell which mappings are mine, which are by plugins
local function remap(mode, lhs, rhs, opts)
  local final_opts = opts or {}
  local desc = final_opts.desc or ''
  final_opts.desc = desc .. ' (My)'
  vim.keymap.set(mode, lhs, rhs, final_opts)
end

remap('n', '<C-q>', '<Cmd>qa<CR>')
-- remap('n', '<Esc>', '<Cmd>nohlsearch<CR>')
remap('n', '<Esc>', onEsc)

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

-- using barbar's commands instead of bprev / bnext, to make sure it stays in sync
remap('n', '(', '<Cmd>BufferPrevious<CR>')
remap('n', ')', '<Cmd>BufferNext<CR>')
-- remap('n', '<C-c>', '<Cmd>bdelete<CR>') -- when closing with bdelete, it also closes current window
remap('n', '<C-c>', '<Cmd>BufferClose<CR>') -- preserves windows structure
remap('n', '<C-d>', '<C-w>c', { desc = 'Close (Delete) window' }) -- preserves windows structure
remap('n', '{', '<Cmd>BufferMovePrevious<CR>')
remap('n', '}', '<Cmd>BufferMoveNext<CR>')
remap('n', '<Leader>b', '<Cmd>BufferPick<CR>', { desc = 'Jump to buffer' })

remap('n', '<C-v>', 'V')
remap('n', 'V', '<C-v>')

remap('n', '<C-u>', 'gUiw') -- Uppercase word in norm/insert
remap('i', '<C-u>', '<Esc>gUiwea') -- FIXME: does not repeat

remap('n', '<C-f>', '*', { desc = '<C-f> is the new *' })
remap('n', '*', '<cmd>echo "<C-f> is the new *"<CR>', { desc = '<C-f> is the new *' })

remap('i', '<C-v>', '<C-r>+', { desc = '<C-v> is paste in insert' })

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
-- remap('i', '<C-j>', '<C-o><C-e>', { desc = 'Scroll down 1 line' })
-- remap('i', '<C-k>', '<C-o><C-y>', { desc = 'Scroll up 1 line' })

remap('n', '<C-j>', '1<C-d>', { desc = 'Scroll down 1 line with cursor steady' })
remap('n', '<C-k>', '1<C-u>', { desc = 'Scroll up 1 line with cursor steady' })
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

    xnoremap <C-f> :<C-u>call g:MyVSetSearch('/')<CR>/<C-R>=@/<CR><CR>
    xnoremap # :<C-u>call g:MyVSetSearch('?')<CR>?<C-R>=@/<CR><CR>
    nnoremap <Leader>f viw:<C-u>call g:MyVSetSearch('/')<CR>:<C-u>set hlsearch<CR>
    xnoremap <Leader>f :<C-u>call g:MyVSetSearch('/')<CR>:<C-u>set hlsearch<CR>
  ]],
  {}
)

-- TODO: check these out, adjust setup
-- -- Diagnostic keymps
-- remap('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
-- remap('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
-- remap('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
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
    vim.highlight.on_yank()
  end,
})

-- Not using FileType, since it's assigned once (and trigger command), but not the following times when
-- the help buffer becomes hidden and revealed again. BufWinEnter is NOT triggered when nvim starts, which is exactly what we want in case we manually resized help window. NOTE: it will still resize the help window when opening another help file.
vim.api.nvim_create_autocmd({ 'BufWinEnter' }, {
  desc = 'My: helpfiles split only vertically',
  group = vim.api.nvim_create_augroup('my-helpfile-splits-vertically', { clear = true }),
  callback = function(arg)
    -- vim.print(arg)
    local buf_num = arg.buf
    local ft = vim.api.nvim_buf_get_option(buf_num, 'filetype')
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

require('lazy').setup({
  --------------------------------------------- COLORS -------------------------------------------------------------------------------------

  -- BranimirE/fix-auto-scroll.nvim, prevent scrolling (centering the cursorline) when changing buffers
  {
    'BranimirE/fix-auto-scroll.nvim',
    -- lua port of https://vim.fandom.com/wiki/Avoid_scrolling_when_switch_buffers
    -- TODO: find workaround for viewport being positioned in the center,:h getwininfo(), :h line(), :h winsaveview(), -> vim.fn
    -- post workaround: https://github.com/neovim/neovim/issues/9179
    config = true,
    event = 'VeryLazy',
  },

  -- RRethy/base16-nvim
  {
    'RRethy/base16-nvim',
    lazy = false,
    priority = math.huge,
    -- config instead of init, to execute after the plugin was loaded
    config = function()
      require('base16-colorscheme').with_config({
        telescope = false,
        indentblankline = false,
        cmp = false,
        notify = false,
        ts_rainbow = false,
        illuminate = false,
        dapui = false,
      })

      -- no need to setup, since we are calling this anyway from our colors
      -- require('base16-colorscheme').setup()

      -- initializing here, to ensure base16 was added to path by Lazy, since we need it in mycolors.lua
      require('mycolors').apply_colors()
    end,
  },

  -- rockyzhang24/arctic.nvim
  {
    'rockyzhang24/arctic.nvim',
    dependencies = { 'rktjmp/lush.nvim' },
    name = 'arctic',
    branch = 'main',
    config = function()
      -- vim.cmd('colorscheme arctic')
      -- vim.cmd.hi('Comment gui=none')
    end,
  },

  { 'lunarvim/darkplus.nvim' },

  { 'folke/tokyonight.nvim' },

  -- loctvl842/monokai-pro.nvim
  {
    'loctvl842/monokai-pro.nvim',
    config = function()
      require('monokai-pro').setup({
        devicons = vim.g.have_nerd_font, -- highlight the icons of `nvim-web-devicons`
        filter = 'pro',
      })
    end,
  },

  -- navarasu/onedark.nvim
  {
    'navarasu/onedark.nvim',
    config = function()
      require('onedark').setup({
        style = 'warmer',
        colors = {
          -- https://www.w3schools.com/colors/colors_picker.asp
          -- TODO: add better search within document '/' highlights (black cursor is not very distinct)
          -- TODO: matchparen highlight not distinct
          cyan = '#56c2a7',
          blue = '#819ae4',
          grey = '#818998',
          fg = '#b6bdc8',
        },
        code_style = {
          comments = 'none',
        },
      })
      -- vim.cmd('colorscheme onedark')
    end,
  },

  { 'rebelot/kanagawa.nvim' },

  -- NvChad/nvim-colorizer.lua
  {
    'NvChad/nvim-colorizer.lua',
    opts = {
      filetypes = { 'lua', 'text' },
      user_default_options = {
        mode = 'virtualtext',
        virtualtext = '',
        names = false,
        RGB = true,
        RRGGBB = true,
        RRGGBBAA = true,
        always_update = false,
      },
    },
  },

  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  -- gc to comment
  { 'numToStr/Comment.nvim', opts = {} },

  -- autoclose parens, quotes etc - does not expose its <CR> function that we need in our custom completion mapping, disabling
  { 'm4xshen/autoclose.nvim', enabled = false, lazy = false, opts = { options = { disable_command_mode = true } } },

  -- HiPhish/rainbow-delimiters.nvim
  {
    'HiPhish/rainbow-delimiters.nvim',
    init = function()
      require('rainbow-delimiters.setup').setup({
        -- strategy = {},
        -- query = {},
        highlight = {
          'RainbowDelimiterBlue',
          'RainbowDelimiterViolet',
          'RainbowDelimiterYellow',
        },
      })
    end,
  },

  -- lukas-reineke/indent-blankline.nvim
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
    config = function()
      require('ibl').overwrite({
        indent = {
          char = '│', -- center(│), left (▏)
        },
        scope = {
          enabled = true, -- the brighter highlighting of the current scope's guide
          show_start = false,
        },
        whitespace = {
          remove_blankline_trail = false,
        },
      })

      -- Replaces the first indentation guide for space indentation with a normal (from docs)
      -- local hooks = require('ibl.hooks')
      -- hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
    end,
  },

  -- olimorris/persisted.nvim
  {
    'olimorris/persisted.nvim',
    lazy = false, -- make sure the plugin is always loaded at startup
    opts = {
      autosave = true, -- automatically save session files when exiting Neovim
      autoload = true, -- automatically load the session for the cwd on Neovim startup
      on_autoload_no_session = function() -- function to run when `autoload = true` but there is no session to load
        vim.notify('No existing session to load.')
      end,
      follow_cwd = false, -- change session file name to match current working directory if it changes
      use_git_branch = false, -- create session files based on the branch of a git enabled repository
      -- ignored_dirs = { vim.fn.expand('$HOME') }, -- trying to ignore home dir also leads to ignoring all the subdirs
      telescope = {
        reset_prompt = true, -- Reset the Telescope prompt after an action?
        mappings = { -- table of mappings for the Telescope extension
          delete_session = '<c-d>',
        },
      },
    },
  },

  -- smoka7/hop.nvim
  {
    'smoka7/hop.nvim',
    -- alternative: mini.jump2d in case this does not work well, this one does not support visual
    version = '*',
    config = function()
      local hop = require('hop')
      hop.setup({
        jump_on_sole_occurrence = false,
        uppercase_labels = true,
        multi_windows = false,
        create_hl_autocmd = true,
        -- keys = 'ASDGHKLQWERTYUIOPZXCVBNMFJ;',
      })
      local hint = require('hop.hint')

      -- remap('n', '<Leader>w', '<Cmd>HopWordAC<CR>') -- old mapping
      remap('n', 'f', function()
        hop.hint_words({ direction = hint.HintDirection.AFTER_CURSOR })
      end, { desc = 'Hop to [F]ollowing words' })
      remap('v', 'f', function()
        hop.hint_words({ direction = hint.HintDirection.AFTER_CURSOR })
      end, { desc = 'Hop to [F]ollowing words' })

      -- remap('n', '<Leader>b', '<Cmd>HopWordBC<CR>') -- old mapping
      remap('n', 't', function()
        hop.hint_words({ direction = hint.HintDirection.BEFORE_CURSOR })
      end, { desc = 'Hop to words before (torwards top)' })
      remap('v', 't', function()
        hop.hint_words({ direction = hint.HintDirection.BEFORE_CURSOR })
      end, { desc = 'Hop to words before (torwards top)' })

      -- WARN: do not remap to "composite" keys that start with <Leader>e, e.g.
      -- remap('n', '<Leader>ef' ...) <-- this will cause a timeout before our "more direct" remap is triggered
      remap('n', '<Leader>e', function()
        hop.hint_words({ direction = hint.HintDirection.AFTER_CURSOR, hint_position = hint.HintPosition.END })
      end, { desc = 'Hop to following words [E]nds' })
      remap('v', '<Leader>e', function()
        hop.hint_words({ direction = hint.HintDirection.AFTER_CURSOR, hint_position = hint.HintPosition.END })
      end, { desc = 'Hop to following words [E]nds' })

      remap('n', '<Leader>k', function()
        hop.hint_lines_skip_whitespace({ direction = hint.HintDirection.BEFORE_CURSOR })
      end, { desc = 'Hop to lines up - [K] motion' })
      remap('v', '<Leader>k', function()
        hop.hint_lines_skip_whitespace({ direction = hint.HintDirection.BEFORE_CURSOR })
      end, { desc = 'Hop to lines up - [K] motion' })

      remap('n', '<Leader>j', function()
        hop.hint_lines_skip_whitespace({ direction = hint.HintDirection.AFTER_CURSOR })
      end, { desc = 'Hop to lines down - [J] motion' })
      remap('v', '<Leader>j', function()
        hop.hint_lines_skip_whitespace({ direction = hint.HintDirection.AFTER_CURSOR })
      end, { desc = 'Hop to lines down - [J] motion' })
    end,
  },

  -- lewis6991/gitsigns.nvim, Adds git related signs to the gutter, as well as utilities for managing changes
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '▒' },
        change = { text = '▒' },
        delete = { text = '▒' },
        topdelete = { text = '▒' },
        changedelete = { text = '▒' },
      },
      on_attach = function()
        local gitsigns = require('gitsigns')
        remap('n', '<Leader>gr', gitsigns.reset_hunk, { desc = '[G]itsigns [R]eset hunk' })
        remap('n', 'gh', gitsigns.preview_hunk, { desc = '[G]itsigns preview [H]unk' })
        -- remap('n', 'gi', gitsigns.preview_hunk_inline, { desc = '[G]itsigns preview hunk [I]nline' })
        remap('n', 'gn', function()
          if vim.wo.diff then
            vim.cmd.normal({ ']c', bang = true })
          else
            gitsigns.nav_hunk('next')
          end
        end, { desc = '[G]itsigns go to [N]ext hunk' })

        remap('n', 'gp', function()
          if vim.wo.diff then
            vim.cmd.normal({ '[c', bang = true })
          else
            gitsigns.nav_hunk('prev')
          end
        end, { desc = '[G]itsigns go to [P]revious hunk' })
      end,
    },
  },

  -- folke/which-key.nvim, shows pending keybinds.
  {
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    config = function() -- This is the function that runs, AFTER loading
      require('which-key').setup({
        plugins = {
          marks = true, -- shows a list of your marks on ' and `
          registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
          -- the presets plugin, adds help for a bunch of default keybindings in Neovim
          -- No actual key bindings are created
          spelling = {
            enabled = false, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
          },
          presets = {
            operators = false, -- adds help for operators like d, y, ...
            motions = false, -- adds help for motions
            text_objects = false, -- help for text objects triggered after entering an operator
            windows = true, -- default bindings on <c-w>
            nav = true, -- misc bindings to work with windows
            z = false, -- we use z as "_d (bindings for folds, spelling and others prefixed with z)
            g = true, -- bindings for prefixed with g
          },
        },
        window = {
          border = 'single',
        },
        triggers_blacklist = {
          n = { 'd' },
        },
      })

      -- Document existing key chains
      require('which-key').register({
        ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
        ['<leader>g'] = { name = '[G]itsigns', _ = 'which_key_ignore' },
      })
    end,
  },

  -- nvim-telescope/telescope.nvim, Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable('make') == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      -- frecency caused e517 error when restoring session with persisted, likely messes up persisted / barbar autcmd interaction
      -- also, my 'my-helpfile-splits-vertically' autocmd stopped working when opening help with telescope
      -- seeing the github issues regarding files on windows, this is likely happening only on windows
      --
      -- { 'nvim-telescope/telescope-frecency.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons' },
    },
    config = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')
      local my_opts = { nowait = true, silent = false }
      require('telescope').setup({
        defaults = {
          mappings = {
            i = {
              ['<c-j>'] = { actions.move_selection_next, type = 'action', opts = my_opts },
              ['<c-k>'] = { actions.move_selection_previous, type = 'action', opts = my_opts },
              ['<c-h>'] = { actions.preview_scrolling_down, type = 'action', opts = my_opts },
              ['<c-l>'] = { actions.preview_scrolling_up, type = 'action', opts = my_opts },
              ['<c-n>'] = false, -- disable to get used to c-j / c-k everywhere
              ['<c-p>'] = false,
              -- ['<c-n>'] = { actions.cycle_history_next, type = 'action', opts = my_opts },
              -- ['<c-p>'] = { actions.cycle_history_prev, type = 'action', opts = my_opts },
            },
            n = {
              ['<c-j>'] = { actions.move_selection_next, type = 'action', opts = my_opts },
              ['<c-k>'] = { actions.move_selection_previous, type = 'action', opts = my_opts },
              ['<c-h>'] = { actions.preview_scrolling_down, type = 'action', opts = my_opts },
              ['<c-l>'] = { actions.preview_scrolling_up, type = 'action', opts = my_opts },
            },
          },
          layout_config = {
            scroll_speed = 1, -- scroll by 1 line at a time, not half page
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
          persisted = {
            layout_config = { width = 0.55, height = 0.55 },
          },
        },
      })

      -- Enable Telescope extensions if they are installed
      pcall(telescope.load_extension, 'fzf')
      pcall(telescope.load_extension, 'ui-select')
      pcall(telescope.load_extension, 'persisted')
      -- pcall(telescope.load_extension, 'frecency')

      -- See `:help telescope.builtin`
      local builtin = require('telescope.builtin')
      -- do not use these, they checkout the selected commit when pressing <CR>, putting git in detached head mode
      -- remap('n', '<leader>gl', builtin.git_commits, { desc = 'Git Log (Tele)' })
      -- remap('n', '<leader>gf', builtin.git_bcommits, { desc = 'Git Log of File (Tele)' })
      remap('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      remap('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      remap('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect choose Telescope builtin' })
      remap('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep in cwd' })
      remap('n', '<leader>sa', builtin.autocommands, { desc = '[S]earch [A]utocmds' })
      remap('n', '<leader>sc', builtin.highlights, { desc = '[S]earch [C]olors' })

      remap('n', '<leader>sf', function()
        builtin.find_files({ hidden = true })
      end, { desc = '[S]earch [F]iles (respecting .gitignore, shows hidden)' })

      -- also for pure lsp diagnostic keybindings, e.g. open diag popup etc :h lspconfig-keybindings
      remap('n', '<leader>d', make_wrapper_fn(builtin.diagnostics, { initial_mode = 'normal' }), { desc = 'Search [D]iagnostics' })
      remap('n', '<leader>sp', '<Cmd>Telescope persisted<CR>', { desc = '[S]earch [P]ersisted session' })

      remap('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = '[/] Fuzzily search in current buffer' })

      -- -- Slightly advanced example of overriding default behavior and theme
      -- remap('n', '<leader>/', function()
      --   -- You can pass additional configuration to Telescope to change the theme, layout, etc.
      --   builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown({
      --     winblend = 10,
      --     previewer = false,
      --   }))
      -- end, { desc = '[/] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      remap('n', '<leader>s/', function()
        builtin.live_grep({
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        })
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      remap('n', '<leader>sn', function()
        builtin.find_files({ cwd = vim.fn.stdpath('config') })
      end, { desc = '[S]earch [N]eovim files' })

      remap('n', '<C-p>', function()
        builtin.find_files(require('telescope.themes').get_dropdown({
          previewer = false,
        }))
      end, { desc = 'Pick a file to open' })

      -- remap('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      -- remap('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
      -- remap('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      -- remap('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    end,
  },

  -- pmizio/typescript-tools.nvim
  {
    'pmizio/typescript-tools.nvim',
    -- typescript completion, calls nvim-lspconfig, spawns an additional tsserver instance for diagnostics
    -- another one if this one does not work: yioneko/vtsls
    enabled = true,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'neovim/nvim-lspconfig',
      -- 'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      -- adding capabilites does not seems to make a difference
      -- local capabilities = require('cmp_nvim_lsp').default_capabilities()
      require('typescript-tools').setup({
        -- capabilities = capabilities,
      })
    end,
  },

  -- neovim/nvim-lspconfig
  {
    'neovim/nvim-lspconfig',
    enabled = true,
    dependencies = {
      -- 'hrsh7th/nvim-cmp',
      -- 'hrsh7th/cmp-nvim-lsp',
      -- versioning of lsp servers here: run once
      -- MasonInstall lua-language-server@3.7.4 stylua@v0.20.0 eslint_d@13.1.2
      -- versions can be found here: https://github.com/mason-org/mason-registry/blob/main/packages/
      { 'williamboman/mason.nvim', opts = {} }, -- just for installation and adding to nvim path, all the config of language servers is manual
      { 'folke/neodev.nvim', opts = {} }, -- this should take care of the lua paths, nvim libraries to be present in completions etc
      -- { 'j-hui/fidget.nvim', opts = {} }, -- shows lsp messages, not sure how useful this is --> lags when only lspconfig is used (no treesitter for better speed)
    },

    config = function()
      local lspconfig = require('lspconfig')

      -- taken from here: https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#borders
      require('lspconfig.ui.windows').default_options.border = 'single' -- border around LspInfo window
      -- local border = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' } -- from telescope help

      -- this is 'rounded'
      -- local border = { { '╭', 'FloatBorder' }, { '─', 'FloatBorder' }, { '╮', 'FloatBorder' }, { '│', 'FloatBorder' }, { '╯', 'FloatBorder' }, { '─', 'FloatBorder' }, { '╰', 'FloatBorder' }, { '│', 'FloatBorder' },
      -- }

      -- taken from here: https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#borders
      -- override floating preview popup's borders, if not provided
      -- tested to work with open diagnosic popup, likely to affect
      local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
      ---@diagnostic disable-next-line: duplicate-set-field
      function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        -- for options see :h nvim_open_win()
        opts.border = opts.border or 'rounded'
        return orig_util_open_floating_preview(contents, syntax, opts, ...)
      end

      -------------------------- server configs -------------------------
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- example to setup lua_ls and enable call snippets
      lspconfig.lua_ls.setup({
        capabilities = capabilities, -- snippets seem to be sent to lsp client even without capabilities
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
          },
        },
      })

      -------------------------- autocmds ---------------------------------
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            remap('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          local t_builtin = require('telescope.builtin')
          map('gd', make_wrapper_fn(t_builtin.lsp_definitions, { initial_mode = 'normal' }), '[G]oto [D]efinition')
          map('gr', make_wrapper_fn(t_builtin.lsp_references, { initial_mode = 'normal' }), '[G]oto [R]eferences')
          map('gD', make_wrapper_fn(vim.lsp.buf.declaration, { initial_mode = 'normal' }), '[G]oto [D]eclaration')
          map('gt', make_wrapper_fn(t_builtin.lsp_type_definitions, { initial_mode = 'normal' }), '[G]oto [T]ype Definition')
          --
          -- -- Fuzzy find all the symbols in your current document.
          -- --  Symbols are things like variables, functions, types, etc.
          -- map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          --
          -- -- Fuzzy find all the symbols in your current workspace.
          -- --  Similar to document symbols, except searches over your entire project.
          -- map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          --
          -- -- Rename the variable under your cursor.
          -- --  Most Language Servers support renaming across files, etc.
          -- map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<F2>', vim.lsp.buf.rename, 'Rename under cursor')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>c', vim.lsp.buf.code_action, '[C]ode [A]ction')

          -- Opens a popup that displays documentation about the word under your cursor
          --  See `:help K` for why this keymap.
          map('K', vim.lsp.buf.hover, 'Hover Documentation')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              group = vim.api.nvim_create_augroup('my-lsp-highlight', { clear = true }),
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              group = vim.api.nvim_create_augroup('my-lsp-clear-highlight', { clear = true }),
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })
    end,
  },

  -- nvimtools/none-ls.nvim, linting (not used as formatter)
  {
    'nvimtools/none-ls.nvim',
    -- None-ls used for linting only (provides diagnostic linter messages AND code actions, unlike nvim-lint, which only does diagnostics)
    -- spawns node instance for its server, but does not close it when nvim exits. At least reuses the same instance when another file is opened
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvimtools/none-ls-extras.nvim', -- https://github.com/nvimtools/none-ls-extras.nvim/tree/main/lua/none-ls
    },
    config = function()
      local null_ls = require('null-ls')
      null_ls.setup({
        -- debug = true, -- for :NullLsInfo, :NullLsLog
        sources = {
          require('none-ls.code_actions.eslint_d'),
          require('none-ls.diagnostics.eslint_d'),
        },
      })
    end,
  },

  -- stevearc/conform.nvim, formatter
  {
    'stevearc/conform.nvim',
    lazy = false,
    opts = {
      -- log_level = vim.log.levels.TRACE,
      notify_on_error = true,
      async = false, -- not legal option here, but just in case
      format_on_save = {
        -- I recommend these options. See :help conform.format for details.
        lsp_fallback = false,
        timeout_ms = 1000,
        async = false, -- not legal option here, but just in case
      },
      formatters = {
        prettierd = { -- set env variable for prettierd to only allow it using local version of prettier
          env = {
            PRETTIERD_LOCAL_PRETTIER_ONLY = 1,
          },
        },
      },
      formatters_by_ft = {
        lua = { 'stylua' },
        -- Use a sub-list to run only the first available formatter, e.g. `{ { 'prettierd', 'prettier' } },`
        javascript = { { 'prettierd', 'prettier' } },
        typescript = { { 'prettierd', 'prettier' } },
        vue = { { 'prettierd', 'prettier' } },
        html = { { 'prettierd', 'prettier' } },
        css = { { 'prettierd', 'prettier' } },
        scss = { { 'prettierd', 'prettier' } },
        json = { { 'prettierd', 'prettier' } },
        jsonc = { { 'prettierd', 'prettier' } },
        tsx = { { 'prettierd', 'prettier' } },
        jsx = { { 'prettierd', 'prettier' } },
        javascriptreact = { { 'prettierd', 'prettier' } },
        typescriptreact = { { 'prettierd', 'prettier' } },
        sass = { { 'prettierd', 'prettier' } },
        yaml = { { 'prettierd', 'prettier' } },
        markdown = { { 'prettierd', 'prettier' } },
      },
    },
  },

  -- hrsh7th/nvim-cmp, Autocompletion
  {
    'hrsh7th/nvim-cmp',
    -- problem: when completion is non-automatic, type:
    -- vim.api<c-j>.nbufs --> there will be no nvim_list_bufs() result
    -- press <c-n> again to re-trigger completion -> now there is!
    -- even more strange: when usng autocompletion, and doing the above sequence,
    -- when typing <c-n> the results are less than before!
    enabled = true,
    dependencies = {
      'echasnovski/mini.nvim', -- make sure mini.pairs is loaded, do not use autoclose.nvim (does not expose its <CR> function)
      { 'hrsh7th/cmp-path' },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'dcampos/cmp-snippy', dependencies = { 'dcampos/nvim-snippy' } },
    },
    config = function()
      local cmp = require('cmp')

      local cmp_kinds = {
        Text = ' ',
        Method = ' ', --  ---  --- 
        Function = 'ƒ ',
        Constructor = ' ', -- 
        Field = ' ',
        Variable = ' ',
        Class = ' ',
        Interface = ' ',
        Module = ' ', --  --  --  --
        Property = ' ',
        Unit = ' ',
        Value = ' ',
        Enum = ' ',
        Keyword = ' ',
        Snippet = ' ',
        Color = ' ',
        File = ' ',
        Reference = ' ',
        Folder = ' ',
        EnumMember = ' ',
        Constant = ' ',
        Struct = ' ',
        Event = ' ',
        Operator = ' ',
        TypeParameter = ' ',
      }

      local cmp_sources = {
        buffer = '[B]',
        nvim_lsp = '[L]',
        nvim_lua = '[Lua]',
      }

      -- NOTE: to be able to test that our hack is working, type:
      -- vim.api.<c-j>n.b.u.f.s (without ., written like this to not save full string inside text)
      -- then `n.v.i.m._.l.i.s.t._.b.u.f.s` should be available in the completion list
      -- if it is missing and only shown with forcing completion (<c-n>), then the hack does not work
      local my_cmp_disabled = true

      -- -- to be triggered by cmp, but cmp almost always fails to trigger it
      -- -- leving it here to document how to detect an active selection
      -- local function my_cmp_cr(fallback)
      --   local compl_info = vim.fn.complete_info()
      --   vim.print('Item selected index: ', compl_info.selected)
      --   if vim.fn.pumvisible() ~= 0 and compl_info.selected ~= -1 then
      --     cmp.confirm()
      --   else
      --     fallback() -- will trigger autoclose.nvim's special indentation adjustment
      --   end
      -- end

      cmp.setup({
        -- weird setting: more useful presentation when cursor is near bottom, but c-j now selects upwards!
        -- view = {
        --   entries = { name = 'custom', selection_order = 'near_cursor' },
        -- },

        ---@diagnostic disable-next-line: missing-fields
        formatting = {
          format = function(entry, vim_item)
            vim_item.kind = cmp_kinds[vim_item.kind] or vim_item.kind
            local name = entry.source.name
            vim_item.menu = cmp_sources[name] or name
            return vim_item
          end,
        },
        snippet = {
          -- REQUIRED - you must specify a snippet engine
          expand = function(args)
            require('snippy').expand_snippet(args.body) -- For `snippy` users.
          end,
        },

        -- hack to conditionally trigger autocompletion and keep it going until <Esc>
        enabled = function()
          -- copied from cmp/config/default
          -- local default_enable = require('cmp.config.default')().enabled
          local disabled = my_cmp_disabled
          disabled = disabled or (vim.api.nvim_buf_get_option(0, 'buftype') == 'prompt')
          disabled = disabled or (vim.fn.reg_recording() ~= '')
          disabled = disabled or (vim.fn.reg_executing() ~= '')
          return not disabled
        end,
        completion = { autocomplete = { 'TextChanged' } },
        -- completion = { autocomplete = { 'InsertEnter', 'TextChanged' } },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = {
          -- does not always get triggered by cmp.nvim -> prefer manual mappings below
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' }, -- higher priority, when there is lsp, other sources will be ignored
        }, {
          { name = 'snippy' },
          { name = 'buffer' },
          { name = 'path' },
        }),

        -- ---@diagnostic disable-next-line: missing-fields
        -- sorting = {
        --   -- from https://github.com/tjdevries/config_manager/blob/master/xdg_config/nvim/after/plugin/completion.lua
        --   comparators = {
        --     cmp.config.compare.offset,
        --     cmp.config.compare.exact,
        --     cmp.config.compare.score,
        --
        --     function(entry1, entry2)
        --       local _, entry1_under = entry1.completion_item.label:find('^_+')
        --       local _, entry2_under = entry2.completion_item.label:find('^_+')
        --       entry1_under = entry1_under or 0
        --       entry2_under = entry2_under or 0
        --       if entry1_under > entry2_under then
        --         return false
        --       elseif entry1_under < entry2_under then
        --         return true
        --       end
        --     end,
        --
        --     cmp.config.compare.kind,
        --     cmp.config.compare.sort_text,
        --     cmp.config.compare.length,
        --     cmp.config.compare.order,
        --   },
        -- },
      })

      remap('i', '<C-j>', function()
        if cmp.visible() then
          cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
        else
          -- vim.print('enabling')
          my_cmp_disabled = false
          cmp.complete()
        end
      end, { desc = 'Autocomplete next' })

      remap('i', '<C-k>', function()
        if cmp.visible() then
          cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
        else
          -- vim.print('enabling')
          my_cmp_disabled = false
          cmp.complete()
        end
      end, { desc = 'Autocomplete prev' })

      remap('i', '<C-l>', function()
        if cmp.visible_docs() then
          cmp.scroll_docs(-4)
        end
      end, { desc = 'Autocomplete scroll docs up' })

      remap('i', '<C-h>', function()
        if cmp.visible_docs() then
          cmp.scroll_docs(4)
        end
      end, { desc = 'Autocomplete scroll docs down' })

      remap('i', '<C-n>', function()
        if not cmp.visible() then
          vim.print('Popup not visible, type <C-j> to complete')
          return
        end
        vim.print('Forcing completion')
        cmp.complete()
      end, { desc = 'Cmp manually mapped' })

      -- also in select mode, when choosing snippet-like entries
      remap({ 'i', 's' }, '<Esc>', function()
        -- vim.print('disabling')
        my_cmp_disabled = true
        -- vim.fn.feedkeys('\\<Esc>', 'n') -- does not work
        vim.cmd([[call feedkeys("\<Esc>", 'n')]])
      end, { desc = '<Esc> also disables autocompletion (hack)' })

      -- mapping <CR> to complete when appropriate, otherwise use mini.pairs' cr() to adjust indentation
      local function my_cr()
        local cr_termcodes = require('mini.pairs').cr()
        vim.api.nvim_feedkeys(cr_termcodes, 'n', false)
      end
      remap('i', '<CR>', function()
        -- vim.fn.pumvisible() ~= 0, also vim.fn.complete_info() fails here, (maybe cmp uses custom
        -- window?) -> using cmp's visible()
        if cmp.visible() then
          if cmp.get_active_entry() then
            cmp.confirm({ select = false, behavior = cmp.ConfirmBehavior.Insert })
          else
            cmp.close()
            my_cr()
          end
        else
          my_cr()
        end
      end, { desc = 'Select completion when popup is open' })
    end,
  },

  -- folke/todo-comments.nvim, Highlight todo, notes, etc in comments
  {
    'folke/todo-comments.nvim',
    -- TODO: test test
    -- FIXME: test
    -- HACK: test
    -- WARN: test
    -- NOTE: test
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      signs = false,
      highlight = {
        keyword = 'wide_fg',
        multiline = false, -- only act on a single line
        after = '', -- do not add colors to the following text
        before = '',
      },
      gui_style = {
        fg = 'bold',
      },
    },
  },

  -- echasnovski/mini.nvim, Collection of various small independent plugins/modules
  {
    'echasnovski/mini.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      -- vim.o.background = 'dark'
      -- vim.cmd.colorscheme('mycolors')

      -- Better Around/Inside textobjects
      -- Auto-jumps to next text object: to jump+visual inside next parens: vi)
      -- For larger scrope, press i) again
      require('mini.ai').setup({ n_lines = 500 }) -- 50 default, 500 suggested by kickstart

      require('mini.surround').setup({
        mappings = {
          add = 's', -- Add surrounding in Normal and Visual modes
          delete = 'sd', -- Delete surrounding
          find = 'sf', -- Find surrounding (to the right)
          find_left = 'sF', -- Find surrounding (to the left)
          highlight = 'sh', -- Highlight surrounding
          replace = 'sc', -- Replace surrounding
          update_n_lines = 'su', -- Update `n_lines` (how many lines are searched to perform surround actions)
          suffix_last = 'l', -- Suffix to search with "prev" method
          suffix_next = 'n', -- Suffix to search with "next" method
        },
      })

      remap('n', 'sw', 'siw', { remap = true }) -- be consistent with cw -> ciw

      -- TODO: replace with something fully customizable, e.g. feline (that also has tabline), rebelot/heirline.nvim (even
      -- more customizable? manually set update triggers), tamton-aquib/staline.nvim also seems good
      local statusline = require('mini.statusline')
      statusline.setup({
        use_icons = vim.g.have_nerd_font,

        -- Whether to set Vim's settings for statusline (make it always shown with
        -- 'laststatus' set to 2). To use global statusline in Neovim>=0.7.0, set
        -- this to `false` and 'laststatus' to 3.
        set_vim_settings = true,
        content = {
          -- default config copied from helpfile
          active = function()
            local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 9999 }) -- our change: always trunc
            local git = MiniStatusline.section_git({ trunc_width = 75 })
            local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
            local filename = MiniStatusline.section_filename({ trunc_width = 140 })
            local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
            local location = MiniStatusline.section_location({ trunc_width = 75 })
            local search = MiniStatusline.section_searchcount({ trunc_width = 75 })

            return MiniStatusline.combine_groups({
              { hl = mode_hl, strings = { mode } },
              { hl = 'MiniStatuslineDevinfo', strings = { git, diagnostics } },
              '%<', -- Mark general truncate point
              { hl = 'MiniStatuslineFilename', strings = { filename } },
              '%=', -- End left alignment
              { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
              { hl = mode_hl, strings = { search, location } },
            })
          end,
          inactive = nil,
        },
      })

      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%-3v'
      end

      require('mini.pairs').setup({})
    end,
  },

  -- romgrk/barbar.nvim, tab line
  {
    'romgrk/barbar.nvim',
    lazy = false,
    dependencies = {
      'lewis6991/gitsigns.nvim', -- OPTIONAL: for git status
      'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
      'olimorris/persisted.nvim', -- to make sure persisted has listener for our autocmd
    },
    init = function()
      vim.g.barbar_auto_setup = false
    end,
    config = function()
      require('barbar').setup({
        clickable = false, -- do not accidentally trigger closing
        animation = true,
        tabpages = true,
        icons = {
          filetype = {
            enabled = false,
          },
          button = ' ', -- '' default, '○' also works well
          modified = { button = '●' }, -- '●' default
          -- do not remove left separator, it will cause filename label shifts when switching between buffers
          -- separator = {
          --   left = '', -- default: '▎'
          --   right = '', -- default: ''
          -- },
          separator_at_end = false,
        },
      })

      -- save buffer order before quitting (from barbar's documentation)
      -- vim.opt.sessionoptions:append('globals') -- already done at top of the file
      vim.api.nvim_create_autocmd({ 'User' }, {
        pattern = 'PersistedSavePre',
        desc = 'Save buffers position in barbar before closing session',
        group = vim.api.nvim_create_augroup('my-persistent-barbar', { clear = true }),
        callback = function()
          -- this will inform barbar to save positions
          vim.api.nvim_exec_autocmds('User', { pattern = 'SessionSavePre' })
        end,
      })

      require('mycolors').apply_colors_barbar()
    end,
    -- version = '^1.0.0', -- optional: only update when a new 1.x version is released
  },

  -- nvim-treesitter/nvim-treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    enabled = true,
    build = ':TSUpdate',
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'lua',
        'luadoc',
        'vim',
        'vimdoc',
        'javascript',
        'typescript',
        'vue',
        'html',
        'css',
        'scss',
        'markdown',
        'json',
        'jsonc',
        'tsx',
        -- do not have parsers:
        -- 'jsx',
        -- 'javascriptreact',
        -- 'typescriptreact',
        -- 'sass',
      },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
    config = function(_, opts)
      -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup(opts)

      -- There are additional nvim-treesitter modules that you can use to interact
      -- with nvim-treesitter. You should go explore a few and see what interests you:
      --
      --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
      --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
      --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    end,
  },

  -- nvim-treesitter/nvim-treesitter-context, sticks surrounding function's signature to the top line
  {
    'nvim-treesitter/nvim-treesitter-context',
    -- shows the surrounding function's signature (line) at the top line (if it was scrolled above), disabled for now until treesitter becomes fast
    enabled = false,
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

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
