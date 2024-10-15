-- if rust-analyzer not installed, run: rustup component add rust-analyzer
return {
  'mrcjkb/rustaceanvim',
  version = '^5', -- Recommended
  lazy = false, -- This plugin is already lazy
  dependencies = { 'neovim/nvim-lspconfig' },
  init = function()
    -- my: set vim.g.rustaceanvim global here, runs before the plugin
  end,
}
