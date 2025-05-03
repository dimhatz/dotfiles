local remap = require('my-helpers').remap

return {
  'nvim-tree/nvim-tree.lua',
  config = function()
    local api = require('nvim-tree.api')

    local function my_on_attach(bufnr)
      api.config.mappings.default_on_attach(bufnr)
      -- vim.keymap.del({ 's', 'n' }, '<Esc>', { buffer = bufnr }) -- fails
      -- our default <Esc> remaps, that close floating windows cause errors in NvimTree
      remap('s', '<Esc>', '<Esc>', { buffer = bufnr, desc = 'Disable our <Esc> mapping in NvimTree - buggy' })
      remap('n', '<Esc>', api.tree.close, { buffer = bufnr, desc = 'Close NvimTree' })
      remap('n', 'd', '<Nop>', { buffer = bufnr, desc = '<Nop>, Delete is only <Del>' })
      remap('n', 'D', '<Nop>', { buffer = bufnr, desc = '<Nop>, Delete is only <Del>' })
      remap('n', '<Del>', api.fs.remove, { buffer = bufnr, desc = 'Delete file' })
    end

    local win_height = vim.api.nvim_get_option_value('lines', { scope = 'global' })
    local win_columns = vim.api.nvim_get_option_value('columns', { scope = 'global' })

    require('nvim-tree').setup({
      on_attach = my_on_attach,
      -- sort = {
      --   sorter = 'case_sensitive',
      -- },
      view = {
        float = {
          -- see nvim_open_win()
          enable = true,
          open_win_config = {
            relative = 'editor',
            border = 'rounded',
            width = 50,
            height = win_height - 5,
            anchor = 'NE',
            row = 1,
            col = win_columns,
          },
        },
      },
      -- renderer = {
      --   group_empty = true,
      -- },
      -- filters = {
      --   dotfiles = true,
      -- },
    })

    remap('n', 'F', '<Cmd>NvimTreeToggle<CR>')
  end,
}
