-- BUG: on windows: :cd projectDir -> :e ~/projectDir/src/somefile.ts -> add an error -> check diagnostics, the error is reported 2 times
-- using '\' has proper behavior, but when session is restored, '/' are used.
-- Workaround: use sessdir in 'sessionoptions', this will result in opening files with :edit src/projectDir/... (not using ~/)
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
      -- capabilities = capabilities, -- <-- passed to nvim-lspconfig
      settings = {
        separate_diagnostic_server = true,
        expose_as_code_action = 'all',
      },
    })
  end,
}
