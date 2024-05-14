return {
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
}
