local remap = require('my-helpers').remap
local make_wrapper_fn = require('my-helpers').make_wrapper_fn
local simulate_keys = require('my-helpers').simulate_keys

return {
  'neovim/nvim-lspconfig',
  enabled = true,
  dependencies = {
    -- 'hrsh7th/nvim-cmp',
    -- 'hrsh7th/cmp-nvim-lsp',
    -- versioning of lsp servers here: run once
    -- MasonInstall lua-language-server@3.13.6 stylua@v2.0.2 eslint_d@14.0.3
    -- NOTE: when upgrading either run an empty nvim or stop all running lsp clients:
    -- vim.lsp.stop_client(vim.lsp.get_clients())
    -- NOTE: versions can be found here: https://github.com/mason-org/mason-registry/blob/main/packages/
    { 'williamboman/mason.nvim', opts = {} }, -- just for installation and adding to nvim path, all the config of language servers is manual
    -- TODO: replace neodev with lazydev, since its deprecated,
    -- WARN: as of 2024-08-04, with lazydev's default setup, when switching to another buffer for the first time,
    -- e.g. going to init.lua from another file, there are a lot of warnings, which disapprear after 2sec
    -- Also, it did not recognize vim.loop.fs_stat in our init.lua, showed it as undefined
    { 'folke/neodev.nvim' }, -- this should take care of the lua paths, nvim libraries to be present in completions etc, do not use opts here, since we will call its setup() manually
    -- {
    --   'folke/lazydev.nvim',
    --   opts = {
    --     library = {
    --       -- See the configuration section for more details
    --       -- Load luvit types when the `vim.uv` word is found
    --       { path = '~/dotfiles/nvim' }, -- <-- without this, globals like vim are not recognized
    --       { path = 'luvit-meta/library', words = { 'vim%.uv' } },
    --     },
    --   },
    -- }, -- this should take care of the lua paths, nvim libraries to be present in completions etc, do not use opts here, since we will call its setup() manually
    -- { 'j-hui/fidget.nvim', opts = {} }, -- shows lsp messages, not sure how useful this is --> lags when only lspconfig is used (no treesitter for better speed)
  },

  config = function()
    -- WARN: make sure to setup neodev BEFORE lspconfig
    -- TODO: remove when switching to lazydev
    require('neodev').setup()

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
      ---@diagnostic disable-next-line: inject-field
      opts.border = opts.border or 'rounded'
      return orig_util_open_floating_preview(contents, syntax, opts, ...)
    end

    -------------------------- diagnostics config ---------------------
    vim.diagnostic.config({
      signs = {
        text = {
          -- ● -- ⏺ -- ⏹ -- ● -- ◆  --  -- 
          [vim.diagnostic.severity.ERROR] = '',
          [vim.diagnostic.severity.WARN] = '',
          [vim.diagnostic.severity.HINT] = '',
          [vim.diagnostic.severity.INFO] = '',
        },
      },
      -- severity_sort = true,
      severity_sort = { reverse = true }, -- hints are now more on top of errors, to review compiler suggestions first
    })
    -------------------------- server configs -------------------------
    local ok_cmp_nvim_lsp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
    if not ok_cmp_nvim_lsp then
      -- for debugging, if we disable cmp, this module should not crash
      vim.notify('My: cmp_nvim_lsp not found. Setting up LuaLS with defaults.', vim.log.levels.WARN)
      lspconfig.lua_ls.setup({})
    else
      -- Lua
      lspconfig.lua_ls.setup({
        -- snippets seem to be sent to lsp client even without passing capabilities
        -- NOTE: with luals there is the following bug: when editing a file from dotfiles, using a
        -- softlinked path (e.g. ~/AppData/Local/nvim...), then highlighting of diagnostics is removed
        -- when the file is saved (with or without neodev).
        capabilities = cmp_nvim_lsp.default_capabilities(),
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
          },
        },
      })

      -- Rust, from https://rust-analyzer.github.io/manual.html
      lspconfig.rust_analyzer.setup({
        settings = {
          ['rust-analyzer'] = {
            imports = {
              granularity = {
                group = 'module',
              },
              prefix = 'self',
            },
            cargo = {
              features = 'all', -- from reddit: to avoid error: file not included in crate hierarchy
              buildScripts = {
                enable = true,
              },
            },
            procMacro = {
              enable = true,
            },
            -- diagnostics = {
            --   enable = true, -- true is default
            -- -- additional diagnostics, source shown as rust-analyzer, not sure if all are the same
            -- -- as those from rustc
            --   enableExperimental = true, -- <-- causes additional diagnostics
            -- },
            checkOnSave = true,
            check = {
              command = 'clippy',
              features = 'all',
              extraArgs = {
                -- from reddit. TODO: configure clippy in its file (or in cargo.toml?), remove the below args
                -- To test if clippy is enabled, add the following func signature: fn add_by_ref(v: &i32) {...}
                -- This results in a warning:
                -- │ │   └╴ this argument (4 byte) is passed by reference, but would be more efficient if passed by value (limit: 8 byte)
                -- │ │       for further information visit https://rust-lang.github.io/rust-clippy/master/index.html#trivially_copy_pass_by_ref
                -- │ │       `-W clippy::trivially-copy-pass-by-ref` implied by `-W clippy::pedantic`
                -- │ │       to override `-W clippy::pedantic` add `#[allow(clippy::trivially_copy_pass_by_ref)]` clippy (trivially_copy_pass_by_ref) [53, 18]
                '--',
                '--no-deps',
                '-Dclippy::all',
                -- '-Dclippy::correctness', -- already 'deny'
                -- '-Dclippy::complexity', -- already 'warn'
                -- '-Wclippy::perf', -- already 'warn'
                '-Wclippy::pedantic',
              },
            },
          },
        },
      })
    end

    -------------------------- autocmds ---------------------------------
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc)
          remap('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        -- Jump to the definition of the word under your cursor.
        --  This is where a variable was first declared, or where a function is defined, etc.
        local ok_t_builtin, t_builtin = pcall(require, 'telescope.builtin')
        if not ok_t_builtin then
          -- for debugging, if we disable telescope, this module should not crash
          vim.notify('My: Telescope builtin not found. Mappings like gd will not be set.', vim.log.levels.WARN)
          return
        end
        map('gd', make_wrapper_fn(t_builtin.lsp_definitions, { initial_mode = 'normal' }), '[G]oto [D]efinition')
        map('gr', make_wrapper_fn(t_builtin.lsp_references, { initial_mode = 'normal', show_line = false }), '[G]oto [R]eferences')
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
        map('<leader>r', function()
          vim.lsp.buf.rename()
          -- WORKAROUND: in neovide, when triggering rename(), the cursor in the prompt is not showing
          -- until we type smth or move cursor with arrows
          if vim.g.neovide then
            vim.defer_fn(function()
              simulate_keys('<Left><Right>', 'n')
            end, 200)
          end
        end, 'Rename under cursor')

        -- Execute a code action, usually your cursor needs to be on top of an error
        -- or a suggestion from your LSP for this to activate.
        map('<leader>c', vim.lsp.buf.code_action, '[C]ode action')

        -- Opens a popup that displays documentation about the word under your cursor
        --  See `:help K` for why this keymap.
        map('K', vim.lsp.buf.hover, 'Hover Documentation')

        -- The following two autocommands are used to highlight references of the
        -- word under your cursor when your cursor rests there for a little while.
        --    See `:help CursorHold` for information about when this is executed
        --
        -- When you move your cursor, the highlights will be cleared (the second autocommand).
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        local buffer = event.buf
        if client and client.server_capabilities.documentHighlightProvider then
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            -- should be auto-cleared when buffer is deleted, or manually on LspDetach
            group = vim.api.nvim_create_augroup('my-lsp-highlight', { clear = false }),
            buffer = buffer,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            -- should be auto-cleared when buffer is deleted, or manually on LspDetach
            group = vim.api.nvim_create_augroup('my-lsp-clear-highlight', { clear = false }),
            buffer = buffer,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd({ 'LspDetach' }, {
            -- not bound to buffer! (from kickstart)
            group = vim.api.nvim_create_augroup('my-lsp-detach', { clear = true }),
            callback = function(ev_detach)
              local detached_buf = ev_detach.buf
              vim.print('My: lsp detached from buffer ' .. detached_buf)
              vim.lsp.util.buf_clear_references(detached_buf)
              vim.api.nvim_clear_autocmds({ group = 'my-lsp-highlight', buffer = detached_buf })
              vim.api.nvim_clear_autocmds({ group = 'my-lsp-clear-highlight', buffer = detached_buf })
            end,
          })
        end
      end,
    })
  end,
}
