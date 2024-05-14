-- prevent scrolling (centering the cursorline) when changing buffers
return {
  'BranimirE/fix-auto-scroll.nvim',
  -- lua port of https://vim.fandom.com/wiki/Avoid_scrolling_when_switch_buffers
  -- TODO: find workaround for viewport being positioned in the center,:h getwininfo(), :h line(), :h winsaveview(), -> vim.fn
  -- post workaround: https://github.com/neovim/neovim/issues/9179
  config = true,
  event = 'VeryLazy',
}
