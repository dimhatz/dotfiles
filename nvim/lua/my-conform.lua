vim.g.rustfmt_autosave = 1

return {
  'stevearc/conform.nvim',
  lazy = false,
  opts = {
    -- log_level = vim.log.levels.TRACE,
    notify_on_error = true,
    async = false, -- not legal option here, but just in case
    format_on_save = {
      -- I recommend these options. See :help conform.format for details.
      lsp_fallback = false,
      timeout_ms = 1000,
      async = false, -- not legal option here, but just in case
    },
    formatters = {
      prettierd = { -- set env variable for prettierd to only allow it using local version of prettier
        env = {
          PRETTIERD_LOCAL_PRETTIER_ONLY = 1,
        },
      },
    },
    formatters_by_ft = {
      css = { 'prettierd', 'prettier' },
      html = { 'prettierd', 'prettier' },
      javascript = { 'prettierd', 'prettier' },
      javascriptreact = { 'prettierd', 'prettier' },
      json = { 'prettierd', 'prettier' },
      jsonc = { 'prettierd', 'prettier' },
      jsx = { 'prettierd', 'prettier' },
      lua = { 'stylua' },
      markdown = { 'prettierd', 'prettier' },
      sass = { 'prettierd', 'prettier' },
      scss = { 'prettierd', 'prettier' },
      tsx = { 'prettierd', 'prettier' },
      typescript = { 'prettierd', 'prettier' },
      typescriptreact = { 'prettierd', 'prettier' },
      vue = { 'prettierd', 'prettier' },
      yaml = { 'prettierd', 'prettier', 'yamlfmt' },
      -- do NOT set rust formatting here, see vim.g.rustfmt_autosave = 1 at the top of this file
      -- TODO: check whether saving this way overwrites undo history, test same behavior with conform
      -- is it to be expected anyway?
      -- rust = { 'rustfmt' },
    },
    default_format_opts = {
      stop_after_first = true,
    },
  },
}
