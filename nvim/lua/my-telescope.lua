local remap = require('my-helpers').remap
local make_wrapper_fn = require('my-helpers').make_wrapper_fn
local normalize_filename = require('my-helpers').normalize_filename
local create_defer_fn_exclusive = require('my-helpers').create_defer_fn_exclusive

-- wrap lines in previewer
vim.api.nvim_create_autocmd('User', {
  pattern = 'TelescopePreviewerLoaded',
  callback = function()
    vim.wo.wrap = true
  end,
})

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
    -- frecency caused e517 error when restoring session with 'persisted', likely messes up persisted / barbar autcmd interaction
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

    local defer_enable_animation_after_moving_selection = create_defer_fn_exclusive(function()
      -- not using just vim.schedule, since sometimes (rarely) the animation would be observed
      vim.g.neovide_scroll_animation_length = 0.1
      -- holding down `(` should only result in one run
    end, 100)

    local function my_move_selection_next(prompt_bufnr)
      if vim.g.neovide then
        -- workaround for scrolling when switching between buffers, see also my-tabline -> switch_to_buffer()
        vim.g.neovide_scroll_animation_length = 0.00
        actions.move_selection_next(prompt_bufnr)
        defer_enable_animation_after_moving_selection()
      else
        actions.move_selection_next(prompt_bufnr)
      end
    end

    local function my_move_selection_previous(prompt_bufnr)
      if vim.g.neovide then
        -- workaround for scrolling when switching between buffers, see also my-tabline -> switch_to_buffer()
        vim.g.neovide_scroll_animation_length = 0.00
        actions.move_selection_previous(prompt_bufnr)
        defer_enable_animation_after_moving_selection()
      else
        actions.move_selection_previous(prompt_bufnr)
      end
    end

    require('telescope').setup({
      defaults = {
        -- file_ignore_patterns = { '.git' .. require('my-helpers').path_delimiter },
        mappings = {
          i = {
            ['<c-j>'] = { my_move_selection_next, type = 'action', opts = my_opts },
            ['<c-k>'] = { my_move_selection_previous, type = 'action', opts = my_opts },
            ['<c-h>'] = { actions.preview_scrolling_down, type = 'action', opts = my_opts },
            ['<c-l>'] = { actions.preview_scrolling_up, type = 'action', opts = my_opts },
            ['<c-v>'] = { '<C-r>+', type = 'command', opts = my_opts },
            ['<c-n>'] = false, -- disable to get used to c-j / c-k everywhere
            ['<c-p>'] = false,
            ['<c-u>'] = false, -- <c-u> / <c-d> are mapped to scroll preview up / down
            ['<c-d>'] = false, -- dont mess with our insert mode <c-d> which is _
            -- ['<c-n>'] = { actions.cycle_history_next, type = 'action', opts = my_opts },
            -- ['<c-p>'] = { actions.cycle_history_prev, type = 'action', opts = my_opts },
          },
          n = {
            ['j'] = { my_move_selection_next, type = 'action', opts = my_opts },
            ['k'] = { my_move_selection_previous, type = 'action', opts = my_opts },
            ['<c-j>'] = { my_move_selection_next, type = 'action', opts = my_opts },
            ['<c-k>'] = { my_move_selection_previous, type = 'action', opts = my_opts },
            ['<c-h>'] = { actions.preview_scrolling_down, type = 'action', opts = my_opts },
            ['<c-l>'] = { actions.preview_scrolling_up, type = 'action', opts = my_opts },
            ['<c-u>'] = false, -- <c-u> / <c-d> are mapped to scroll preview up / down
            ['<c-d>'] = false, -- dont mess with our insert mode <c-d> which is _
          },
        },
        -- layout_strategy = 'horizontal',
        layout_config = {
          scroll_speed = 1, -- scroll by 1 line at a time, not half page
          horizontal = {
            -- specific to horizontal layout
            height = 0.8,
            width = 0.99,
            preview_width = 0.66,
          },
        },
      },
      extensions = {
        ['ui-select'] = {
          -- this is what makes code actions (and other nvim actions) go through telescope
          require('telescope.themes').get_dropdown({ initial_mode = 'normal' }),
        },
      },
    })

    -- Enable Telescope extensions if they are installed
    pcall(telescope.load_extension, 'fzf')
    pcall(telescope.load_extension, 'ui-select')
    -- pcall(telescope.load_extension, 'frecency')

    -- See `:help telescope.builtin`
    local builtin = require('telescope.builtin')
    -- do not use these, they checkout the selected commit when pressing <CR>, putting git in detached head mode
    -- remap('n', '<leader>gl', builtin.git_commits, { desc = 'Git Log (Tele)' })
    -- remap('n', '<leader>gf', builtin.git_bcommits, { desc = 'Git Log of File (Tele)' })
    remap('n', '<leader>sh', builtin.help_tags, { desc = 'Search [H]elp' })
    remap('n', '<leader>sk', builtin.keymaps, { desc = 'Search [K]eymaps' })
    remap('n', '<leader>ss', builtin.builtin, { desc = '[S]elect Telescope builtin and search' })
    -- TODO: support extra feature: when searching for: sometext  *.txt <-- note 2 spaces, the *.txt is sent to rg with -g param for globbing
    -- example from tj devries https://www.youtube.com/watch?v=xdXE1tOT-qg,
    -- https://github.com/tjdevries/advent-of-nvim/blob/13d4ec68a2a81f27264f3cc73dd7cd8c047aab87/nvim/lua/config/telescope/multigrep.lua
    -- maybe there is an option that will search in filenames instead of globbing, if so, how to search for 2 different patterns? e.g. .txt + .ts
    remap('n', '<leader>sg', builtin.live_grep, { desc = 'Search by [G]rep in cwd' })
    remap('n', '<leader>sa', builtin.autocommands, { desc = 'Search [A]utocmds' })
    remap('n', '<leader>sc', builtin.highlights, { desc = 'Search [C]olors' })
    remap('n', '<leader>sr', make_wrapper_fn(builtin.resume, { initial_mode = 'normal' }), { desc = 'Search [R]esume previous' })

    local find_command = { 'rg', '--files', '--hidden', '--glob=!.git/*', '--color=never' }
    remap('n', '<leader>sf', function()
      -- just using { hidden = true } will also show garbage from .git folder
      -- file_ignore_patterns = { '^.git/', '%.git/.*' } in defaults does not fix this on windows.
      -- Alternatively: a global config for rg, or a top-level .gitignore file in home
      -- directory, which would include .git as ignored dir
      -- Alternatively2: add to defaults:
      -- file_ignore_patterns = { '.git' .. require('my-helpers').path_delimiter },
      -- this will perform secondary filtering in lua after rg returns results
      builtin.find_files({ find_command = find_command })
    end, { desc = 'Search [F]iles (respecting .gitignore, shows hidden)' })

    remap('n', '<C-p>', function()
      builtin.find_files(require('telescope.themes').get_dropdown({
        previewer = false,
        find_command = find_command,
      }))
    end, { desc = 'Pick a file to open' })

    -- also for pure lsp diagnostic keybindings, e.g. open diag popup etc :h lspconfig-keybindings
    remap(
      'n',
      '<leader>d',
      make_wrapper_fn(builtin.diagnostics, {
        initial_mode = 'normal',
        layout_config = {
          scroll_speed = 1, -- scroll by 1 line at a time, not half page
          horizontal = {
            -- specific to horizontal layout
            height = 0.8,
            width = 0.99,
            preview_width = 0.5,
          },
        },
        -- diagnostics-specific:
        line_width = 50,
        path_display = function(_, path)
          -- show filename relative to current dir or ~ if possible
          -- the builtin options do not handle windows paths correctly,
          -- hence the workaround:
          return vim.fn.fnamemodify(normalize_filename(path), ':~:.')
        end,
      }),
      { desc = 'Search [D]iagnostics' }
    )

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
    end, { desc = 'Search [/] in Open Files' })

    local function search_open_buffers()
      builtin.buffers({
        initial_mode = 'normal',
        sort_mru = true,
        attach_mappings = function(_, map)
          map('n', '<C-c>', function(prompt_bufnr)
            -- TODO: refreshing results is currently not supported in telescope, see issue:
            -- https://github.com/nvim-telescope/telescope.nvim/issues/2912
            local action_state = require('telescope.actions.state')
            -- local current_picker = action_state.get_current_picker(prompt_bufnr) -- picker state
            local entry = action_state.get_selected_entry()
            -- `:lua vim.cmd.bdelete(<buf>)` or vim.cmd.bwipeout does not work for some reason
            -- neither :bdelete <buf>, or vim.api.nvim_buf_delete(<buf>, {})
            -- when the window is open. The mini library works, but results are not updated
            -- Workaround (re-opens telescope window)
            require('telescope.actions').close(prompt_bufnr)
            require('mini.bufremove').delete(entry.bufnr)
            -- TODO: make it resume at the same position too
            vim.schedule(search_open_buffers) -- search_open_buffers() is current, remap()'ed function

            -- Another solution, without flickering, but results in broken highlight (some word parts have incorrect colors)
            -- for .ts buffers that have not been focused / highlighted yet, like when restoring a session:
            -- require('mini.bufremove').delete(entry.bufnr)
            -- require('telescope.actions').delete_buffer(prompt_bufnr) -- we manually update the entries
          end)
          -- returning true will also keep the default mappings for this picker
          return true
        end,
      })
    end

    remap('n', '<leader><leader>', search_open_buffers, { desc = 'Find existing buffers, close selected with <C-c>' })

    local search_dirs_cache = nil
    remap('n', '<leader>sd', function()
      local search_dirs = {}
      if search_dirs_cache then
        search_dirs = search_dirs_cache
      else
        local runtime_paths = vim.opt.runtimepath:get()
        for _, path in ipairs(runtime_paths) do
          local help_path = path .. '/doc'
          help_path = normalize_filename(help_path)
          if vim.fn.isdirectory(help_path) == 1 then
            table.insert(search_dirs, help_path)
          end
        end
        search_dirs_cache = search_dirs
      end
      -- builtin.grep_string
      builtin.live_grep({ search_dirs = search_dirs })
    end, { desc = 'Live grep vim and plugins [D]ocumentation' })

    remap('n', '<leader>f', function()
      builtin.grep_string({ initial_mode = 'normal' })
    end, { desc = 'Find word under cursor in working dir' })

    remap('x', '<leader>f', function()
      local selected_strings = vim.fn.getregion(vim.fn.getpos('v'), vim.fn.getpos('.'), { type = vim.fn.mode() })
      if #selected_strings == 0 then
        vim.notify('My telescope: invalid visual selection', vim.log.levels.ERROR)
        return
      elseif #selected_strings ~= 1 then
        vim.notify('My telescope: selected too many lines', vim.log.levels.ERROR)
        return
      end
      builtin.grep_string({ search = selected_strings[1], initial_mode = 'normal' })
    end, { desc = 'Find word under cursor in working dir' })
  end,
}
