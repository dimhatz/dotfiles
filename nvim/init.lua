-- TODO: map <c-m> to <c-p>
-- NOTE: use :lua vim.diagnostic.setqflist() to all diagnostics into a quickfix list
if vim.g.neovide then
  vim.g.neovide_refresh_rate = 60
  vim.g.neovide_cursor_animate_in_insert_mode = false
  -- vim.g.neovide_no_idle = true
  -- TODO: set options for subpixel rendering
end

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
vim.opt.timeoutlen = 300

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
vim.opt.completeopt = 'menu,menuone,noselect' -- as suggested by cmp plugin, removing noselect does not seem to make a difference

vim.opt.foldmethod = 'indent'
vim.opt.foldlevel = 999

-- Set highlight on search, will be cleared on <Esc> in normal
vim.opt.hlsearch = true

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

local remap = vim.keymap.set

remap('n', '<C-q>', '<Cmd>qa<CR>')
-- remap('n', '<Esc>', '<Cmd>nohlsearch<CR>')
remap('n', '<Esc>', onEsc)

remap('n', ';', ':')
remap('n', ':', ';')

remap('n', '<C-s>', '<Cmd>write<CR>')
remap('i', '<C-s>', '<Esc><Cmd>write<CR>')

-- do not copy text into registers when replacing it
remap('n', 'c', '"_c')
remap('v', 'c', '"_c')
remap('n', 'x', '"_x', { desc = 'delete char into black hole' })
remap('n', 'z', '"_d', { desc = 'delete into black hole' })
remap('n', 'Z', '"_D', { desc = 'delete into black hole' })
remap('n', 'X', '<cmd>echo "use Z to delete into black hole till end of line"<CR>')
remap('n', 'zz', '"_dd', { desc = 'delete line into black hole' })
remap('n', 'zw', '"_daw') -- be consistent with dw -> daw
remap('v', 'x', '"_d')
remap('v', 'z', '"_d')

remap('n', 'j', 'gj') -- navigate wrapped lines
remap('n', 'k', 'gk')

-- using barbar's commands instead of bprev / bnext, to make sure it stays in sync
remap('n', '(', '<Cmd>BufferPrevious<CR>')
remap('n', ')', '<Cmd>BufferNext<CR>')
remap('n', '<C-c>', '<Cmd>bdelete<CR>') -- avoiding '<Cmd>BufferClose<CR>' as it does not remove help window when closing it
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
remap('n', 'mm', 'za', { desc = 'toggle fold (za)' })

-- remap('v', 'p', 'p:let @+=@0<CR>', { desc = 'Pasting in visual does not override the + register', silent = true }) -- original from my vimrc
remap('v', 'p', 'p:let @v=@+|let @+=@0<CR>', { desc = 'Pasting in visual stores the overwritten text in "v register', silent = true })
-- remap('v', 'p', 'p:let @v=@+<Bar>let @+=@0<CR>', { desc = 'Pasting in visual stores the overwritten text in "v register', silent = true }) -- also works

remap('n', '<C-h>', '<C-e>', { desc = 'Scroll down 1 line' })
remap('n', '<C-l>', '<C-y>', { desc = 'Scroll up 1 line' })
remap('i', '<C-j>', '<C-o><C-e>', { desc = 'Scroll down 1 line' })
remap('i', '<C-k>', '<C-o><C-y>', { desc = 'Scroll up 1 line' })
remap('n', '<C-j>', '1<C-d>', { desc = 'Scroll down 1 line with cursor steady' })
remap('n', '<C-k>', '1<C-u>', { desc = 'Scroll up 1 line with cursor steady' })
-- remap('n', '<A-j>', '1<C-d>', { desc = 'Scroll down 1 line with cursor steady' }) -- same as above, but with Alt, alacritty re-exposes (in flashes) the mouse if its inside terminal
-- remap('n', '<A-k>', '1<C-u>', { desc = 'Scroll up 1 line with cursor steady' })
remap('n', '<C-m>', 'M', { desc = 'Put cursor in the center of the screen' })
remap('n', 'M', 'zz', { desc = 'Center the screen on the cursor' })

-- TODO: find workaround for viewport being positioned in the center,:h getwininfo(), :h line(), :h winsaveview(), -> vim.fn
-- post workaround: https://github.com/neovim/neovim/issues/9179
remap('n', '<C-z>', ':e!<CR>', { desc = 'Undo all changes since file last saved' })

remap('n', '<C-F1>', '<Cmd>set foldlevel=1<CR>', { desc = 'Fold all text at level 1' })
remap('n', '<C-F2>', '<Cmd>set foldlevel=2<CR>', { desc = 'Fold all text at level 2' })
remap('n', '<C-F3>', '<Cmd>set foldlevel=3<CR>', { desc = 'Fold all text at level 3' })
remap('n', '<C-F4>', '<Cmd>set foldlevel=4<CR>', { desc = 'Fold all text at level 4' })
remap('n', '<C-F5>', '<Cmd>set foldlevel=5<CR>', { desc = 'Fold all text at level 5' })
remap('n', '<C-F6>', '<Cmd>set foldlevel=6<CR>', { desc = 'Fold all text at level 6' })
remap('n', '<C-F7>', '<Cmd>set foldlevel=7<CR>', { desc = 'Fold all text at level 7' })
remap('n', '<C-F10>', '<Cmd>set foldlevel=999<CR>', { desc = 'Unfold all' })

-- now C-p and C-n autocomplete the beginning of the command and search.
remap('c', '<C-p>', '<Up>', { desc = 'Autocomplete in command mode' })
remap('c', '<C-n>', '<Down>', { desc = 'Autocomplete in command mode' })

remap('n', 'cw', 'ciw')
remap('n', 'dw', 'daw')

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

-- -- Diagnostic keymps
-- remap('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
-- remap('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
-- remap('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
-- remap('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

------------------------------------------------------- AUTOCOMMANDS --------------------------------------------------------------------------

--  See `:help lua-guide-autocommands`
vim.api.nvim_create_autocmd({ 'FileType' }, {
  desc = 'gd inside helpfiles jumps to links',
  group = vim.api.nvim_create_augroup('my-helpfile-jump', { clear = true }),
  pattern = { 'help' },
  callback = function(opts)
    remap('n', 'gd', '<C-]>', { silent = true, buffer = opts.buf, desc = 'Go to link inside helpfile' })
  end,
})

--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
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

require('lazy').setup({
  --------------------------------------------- COLORS -------------------------------------------------------------------------------------
  {
    'lunarvim/darkplus.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      -- vim.cmd.colorscheme('darkplus')
      -- vim.cmd.hi 'Comment gui=none'
    end,
  },
  {
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      -- vim.cmd.colorscheme 'tokyonight-night'
      -- vim.cmd.hi 'Comment gui=none'
    end,
  },

  {
    'loctvl842/monokai-pro.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      -- vim.cmd.colorscheme 'monokai-pro-octagon'
    end,
    config = function()
      require('monokai-pro').setup({
        devicons = vim.g.have_nerd_font, -- highlight the icons of `nvim-web-devicons`
        filter = 'pro',
      })
    end,
  },

  -- both below use 'onedark' colorscheme name

  -- {
  --   'olimorris/onedarkpro.nvim',
  --   priority = 1000, -- Ensure it loads first
  --   init = function()
  --     vim.cmd 'colorscheme onedark'
  --   end,
  -- },
  {
    'navarasu/onedark.nvim',
    lazy = false,
    priority = 1000, -- Ensure it loads first
    init = function()
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
      vim.cmd('colorscheme onedark')
      -- vim.cmd.hi 'Comment gui=none' -- TODO: investigate
    end,
  },

  {
    'rebelot/kanagawa.nvim',
    priority = 1000, -- Ensure it loads first
    init = function()
      -- vim.cmd 'colorscheme kanagawa'
    end,
  },

  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  -- gc to comment
  { 'numToStr/Comment.nvim', opts = {} },

  -- autoclose parens, quotes etc
  { 'm4xshen/autoclose.nvim', opts = {} },

  {
    'HiPhish/rainbow-delimiters.nvim',
    init = function()
      ---@type rainbow_delimiters.config
      require('rainbow-delimiters.setup').setup({
        -- strategy = {},
        -- query = {},
        highlight = {
          'RainbowDelimiterYellow',
          'RainbowDelimiterViolet',
          'RainbowDelimiterBlue',
          -- 'RainbowDelimiterRed',
          -- 'RainbowDelimiterCyan',
          -- -- 'RainbowDelimiterGreen',
          -- -- 'RainbowDelimiterOrange',
        },
      })
    end,
  },

  { -- alternative: mini.jump2d in case this does not work well, this one does not support visual
    'smoka7/hop.nvim',
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

      -- vim.cmd.hi('HopNextKey gui=bold guifg=#77ff33') -- bright green
      -- vim.cmd.hi('HopNextKey gui=bold guifg=#00ffff') -- bright cyan
      vim.cmd.hi('HopNextKey gui=bold guifg=#ffff00') -- bright yellow
      vim.cmd.hi('HopNextKey1 gui=bold guifg=#ffff00') -- bright yellow
      vim.cmd.hi('HopNextKey2 gui=bold guifg=#ffff00') -- bright yellow
    end,
    -- TODO: create highlight groups for better appearance, :h hop-highlights
  },

  { -- Adds git related signs to the gutter, as well as utilities for managing changes
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

  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    config = function() -- This is the function that runs, AFTER loading
      require('which-key').setup()

      -- Document existing key chains
      require('which-key').register({
        ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
        ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
        ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
        ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
        ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
        ['<leader>g'] = { name = '[G]itsigns', _ = 'which_key_ignore' },
      })
    end,
  },

  { -- Fuzzy Finder (files, lsp, etc)
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

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- The easiest way to use Telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of `help_tags` options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- Telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup({
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        -- defaults = {
        --   mappings = {
        --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
        --   },
        -- },
        -- pickers = {}
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      })

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require('telescope.builtin')
      remap('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      remap('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      remap('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      remap('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      remap('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      remap('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      remap('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      remap('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      remap('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      -- remap('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      -- Slightly advanced example of overriding default behavior and theme
      remap('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end, { desc = '[/] Fuzzily search in current buffer' })

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
    end,
  },

  { -- typescript completion, calls nvim-lspconfig, spawns an additional tsserver instance for diagnostics
    'pmizio/typescript-tools.nvim',
    enabled = true,
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    opts = {
      -- settings = {
      --   separate_diagnostic_server = true,
      -- }
    },
  },

  {
    'neovim/nvim-lspconfig',
    enabled = true,
    dependencies = {
      -- versioning of lsp servers here: run once
      -- MasonInstall lua-language-server@3.7.4 stylua@v0.20.0 eslint_d@13.1.2
      -- versions can be found here: https://github.com/mason-org/mason-registry/blob/main/packages/
      { 'williamboman/mason.nvim', opts = {} }, -- just for installation and adding to nvim path, all the config of language servers is manual
      { 'folke/neodev.nvim', opts = {} }, -- this should take care of the lua paths, nvim libraries to be present in completions etc
      -- { 'j-hui/fidget.nvim', opts = {} }, -- shows lsp messages, not sure how useful this is --> lags when only lspconfig is used (no treesitter for better speed)
    },

    config = function()
      local lspconfig = require('lspconfig')

      -------------------------- server configs -------------------------
      -- example to setup lua_ls and enable call snippets
      lspconfig.lua_ls.setup({
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
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          -- Find references for the word under your cursor.
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          -- -- Jump to the implementation of the word under your cursor.
          -- --  Useful when your language has ways of declaring types without an actual implementation.
          -- map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          --
          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
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

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

          -- Opens a popup that displays documentation about the word under your cursor
          --  See `:help K` for why this keymap.
          map('K', vim.lsp.buf.hover, 'Hover Documentation')

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })
    end,
  },

  { -- None-ls used for linting only (provides diagnostic linter messages AND code actions, unlike nvim-lint, which only does diagnostics)
    -- spawns node instance for its server, but does not close it when nvim exits. At least reuses the same instance when another file is opened
    'nvimtools/none-ls.nvim',
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

  { -- Autoformat
    'stevearc/conform.nvim', -- TODO: switch to original repo once my fix is merged
    lazy = false,
    -- keys = {
    --   {
    --     '<leader>f',
    --     function()
    --       require('conform').format({ async = false, lsp_fallback = false })
    --     end,
    --     mode = 'n',
    --     desc = '[F]ormat buffer',
    --   },
    -- },
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

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      { 'hrsh7th/cmp-buffer' }, -- apparently not needed, text suggestions show anyway, also messes up results, showing text on top
      { 'hrsh7th/cmp-path' },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'dcampos/cmp-snippy', dependencies = { 'dcampos/nvim-snippy' } },
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        snippet = {
          -- REQUIRED - you must specify a snippet engine
          expand = function(args)
            require('snippy').expand_snippet(args.body) -- For `snippy` users.
          end,
        },
        completion = { autocomplete = false },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-l>'] = cmp.mapping.scroll_docs(-4),
          ['<C-h>'] = cmp.mapping.scroll_docs(4),
          ['<C-d>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'buffer' },
          { name = 'path' },
          { name = 'snippy' },
        }),
      })
    end,
  },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
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
      remap('n', 'ds', 'sd', { remap = true })
      remap('n', 'cs', 'sc', { remap = true })

      local statusline = require('mini.statusline')
      statusline.setup({ use_icons = vim.g.have_nerd_font })

      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },

  { -- tab line
    'romgrk/barbar.nvim',
    dependencies = {
      'lewis6991/gitsigns.nvim', -- OPTIONAL: for git status
      'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
    },
    init = function()
      vim.g.barbar_auto_setup = false
    end,
    opts = {
      animation = true,
      tabpages = true,
    },
    -- version = '^1.0.0', -- optional: only update when a new 1.x version is released
  },

  { -- Highlight, edit, and navigate code
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
