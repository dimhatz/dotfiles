-- docs at :help nvim-treesitter
-- We use treesitter only for rainbow delimiters(triggered on esc), the rest of highlighting is provided by syntax + lsp
return {
  'nvim-treesitter/nvim-treesitter',
  enabled = true,
  lazy = false,
  branch = 'main',
  -- build = ':TSUpdate',
  config = function()
    local ts = require('nvim-treesitter')
    local langs = {
      'bash',
      'c',
      'lua',
      'luadoc',
      'vim',
      'vimdoc',
      'javascript',
      'typescript',
      'vue',
      'html',
      'css',
      'scss',
      'markdown',
      'json',
      'jsonc',
      'tsx',
      'rust',
      -- do not have parsers:
      -- 'jsx',
      -- 'javascriptreact',
      -- 'typescriptreact',
      -- 'sass',
    }

    -- async, no-op if the parsers are already installed
    ts.install(langs, { max_jobs = 1 }) -- summary = true,

    -- disable lua treesitter
    vim.api.nvim_create_autocmd({ 'FileType' }, {
      desc = 'My: disable treesitter in lua files',
      group = vim.api.nvim_create_augroup('my-disable-treesitter-in-lua', { clear = true }),
      pattern = { 'lua' },
      callback = function()
        vim.treesitter.stop()
      end,
    })

    -- enable treesitter for typescript, javascript
    vim.api.nvim_create_autocmd({ 'FileType' }, {
      desc = 'My: enable treesitter',
      group = vim.api.nvim_create_augroup('my-enable-treesitter', { clear = true }),
      pattern = { 'typescript', 'javascript' },
      callback = function()
        vim.treesitter.start()
      end,
    })
  end,
}
