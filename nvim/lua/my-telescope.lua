local remap = require('my-helpers').remap
local make_wrapper_fn = require('my-helpers').make_wrapper_fn
-- nvim-telescope/telescope.nvim, Fuzzy Finder (files, lsp, etc)
return {
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
}
