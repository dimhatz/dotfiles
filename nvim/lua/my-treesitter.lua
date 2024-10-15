-- docs at :help nvim-treesitter
return {
  'nvim-treesitter/nvim-treesitter',
  enabled = true,
  build = ':TSUpdate',
  opts = {
    ensure_installed = {
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
    },
    -- Autoinstall languages that are not installed
    auto_install = true,
    highlight = {
      enable = false,
      -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
      --  If you are experiencing weird indenting issues, add the language to
      --  the list of additional_vim_regex_highlighting and disabled languages for indent.
      additional_vim_regex_highlighting = { 'ruby' },
    },
    -- disable indent, since we use mini-indentscope, == operator is not that useful too, since
    -- we use autoformatters anyway. rainbow-delimiters that requires treesitter seems to not be
    -- affected by this, continues to work.
    indent = { enable = false, disable = { 'ruby' } },
    incremental_selection = { enable = false },
  },
  config = function(_, opts)
    require('nvim-treesitter.configs').setup(opts)

    -- disable lua treesitter
    vim.api.nvim_create_autocmd({ 'FileType' }, {
      desc = 'My: disable treesitter in lua files',
      group = vim.api.nvim_create_augroup('my-disable-treesitter-in-lua', { clear = true }),
      pattern = { 'lua' },
      callback = function(_)
        -- local buffer = options.buf -- options -> from this func's the argument
        vim.treesitter.stop()
      end,
    })

    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  end,
}
