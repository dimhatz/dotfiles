local remap = require('my-helpers').remap
local make_wrapper_fn = require('my-helpers').make_wrapper_fn

return {
  'neovim/nvim-lspconfig',
  enabled = true,
  dependencies = {
    -- 'hrsh7th/nvim-cmp',
    -- 'hrsh7th/cmp-nvim-lsp',
    -- versioning of lsp servers here: run once
    -- MasonInstall lua-language-server@3.7.4 stylua@v0.20.0 eslint_d@13.1.2
    -- versions can be found here: https://github.com/mason-org/mason-registry/blob/main/packages/
    { 'williamboman/mason.nvim', opts = {} }, -- just for installation and adding to nvim path, all the config of language servers is manual
    { 'folke/neodev.nvim' }, -- this should take care of the lua paths, nvim libraries to be present in completions etc, do not use opts here, since we will call its setup() manually
    -- { 'j-hui/fidget.nvim', opts = {} }, -- shows lsp messages, not sure how useful this is --> lags when only lspconfig is used (no treesitter for better speed)
  },

  config = function()
    -- IMPORTANT: make sure to setup neodev BEFORE lspconfig
    require('neodev').setup({
      -- add any options here, or leave empty to use the default settings
    })

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
    })
    -------------------------- server configs -------------------------
    local ok_cmp_nvim_lsp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
    if not ok_cmp_nvim_lsp then
      -- for debugging, if we disable cmp, this module should not crash
      vim.notify('My: cmp_nvim_lsp not found. Setting up LuaLS with defaults.', vim.log.levels.WARN)
      lspconfig.lua_ls.setup({})
    else
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
        map('<leader>c', make_wrapper_fn(vim.lsp.buf.code_action, { initial_mode = 'normal' }), '[C]ode [A]ction')

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
}
