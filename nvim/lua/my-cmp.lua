local remap = require('my-helpers').remap

-- TODO: check out https://github.com/saghen/blink.cmp, see if it's mature enough
-- has borders, disabling menu, fuzzying, documentation preview, snippets etc

return {
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
    My_cmp_disabled = true -- <-- global, used from mappings with <Cmd>lua My_cmp_disabled=true<CR>

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

    local default_enabled_fn = require('cmp.config.default')().enabled
    if type(default_enabled_fn) ~= 'function' then
      local msg = 'My: req(cmp.config.default).enabled has unexpected type: ' .. type(default_enabled_fn)
      vim.notify(msg, vim.log.levels.ERROR)
      vim.notify('My: Will not init cmp', vim.log.levels.ERROR)
      return
    end

    cmp.setup({
      -- even when lsp suggests to preselect an item, do not do it (results in needing <c-j><c-k> to
      -- insert selected text)
      preselect = cmp.PreselectMode.None,
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
        local disabled = My_cmp_disabled
        disabled = disabled or (not default_enabled_fn())
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
      if vim.fn.reg_recording() ~= '' then
        -- Cmp is incompatible with macros, ensure it never triggers. The cmp's
        -- default enabled() should  prevent this, but it does not always work.
        return
      end
      if cmp.visible() then
        cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
      else
        -- vim.print('enabling')
        My_cmp_disabled = false
        cmp.complete()
      end
    end, { desc = 'Autocomplete next' })

    remap('i', '<C-k>', function()
      if vim.fn.reg_recording() ~= '' then
        return
      end
      if cmp.visible() then
        cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
      else
        -- vim.print('enabling')
        My_cmp_disabled = false
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
      else
        vim.lsp.buf.signature_help()
      end
    end, { desc = 'Autocomplete scroll docs down / Lsp signature help (when no popup)' })

    remap('i', '<C-n>', function()
      if not cmp.visible() then
        vim.print('Popup not visible, type <C-j> to complete')
        return
      end
      vim.print('Forcing completion')
      cmp.complete()
    end, { desc = 'Cmp force complete' })

    -- also in select mode, when choosing snippet-like entries
    remap(
      { 'i', 's' },
      '<Esc>',
      '<Esc><Cmd>lua My_cmp_disabled=true require("my-helpers").update_treesitter_tree()<CR>',
      -- '<Cmd>lua My_cmp_disabled=true<CR><Esc><Cmd>lua require("my-helpers").update_treesitter_tree()<CR>',
      { desc = '<Esc> also disables autocompletion, updates rainbow parens (hack)' }
    )

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
}
