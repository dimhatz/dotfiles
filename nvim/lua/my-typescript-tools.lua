return {
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
}
