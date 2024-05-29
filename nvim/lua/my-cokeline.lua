local remap = require('my-helpers').remap

return {
  'willothy/nvim-cokeline',
  dependencies = {
    'nvim-lua/plenary.nvim', -- Required for v0.4.0+
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    -- TODO: to prevent constant refreshes of tabline, we can use the following hack:
    -- evaluate (with vim.cmd?) `v:lua.cokeline.tabline()` and set the value to
    -- vim.opt.tabline using autocmds (after buffer open / close / modified, same for window etc)
    -- First, use os.clock() to profile the evaluation over 10000 iterations
    --
    -- local count = 0

    local local_cokeline = require('cokeline') -- to differentiate from global, which we use too
    local mappings = require('cokeline.mappings')
    local is_picking_focus = mappings.is_picking_focus
    local c = require('mycolors').colors
    local_cokeline.setup({
      show_if_buffers_are_at_least = 0,
      buffers = {
        new_buffers_position = 'next',
      },
      pick = {
        letters = 'fdjklsaghnmxcvbziowerutyqpASDFJKLGHNMXCVBZIOWERTYQP',
        use_filename = false,
      },
      -- tabs = { -- no tabs for now
      --   placement = 'right',
      --   components = {},
      -- },
      default_hl = {
        fg = function(buffer)
          if buffer.is_focused then
            return c.whitest
          else
            return buffer.is_modified and c.peach or c.base05fg
          end
        end,
        bg = function(buffer)
          -- count = count + 1
          -- vim.print(count)
          if buffer.is_focused then
            return buffer.is_modified and c.peach_dark or c.blue_dark
          else
            return c.base01
          end
        end,
        fill_hl = 'TabLineFill',
      },
      components = {
        {
          text = function(buffer)
            local pick_letter = is_picking_focus() and buffer.pick_letter or ' '
            pick_letter = string.upper(pick_letter)
            -- properly centered with iosevka + neovide: • -- ∎
            local icon = buffer.is_modified and ' •▕' or '  ▕' -- • -- ● -- big cirlcle not centered correctly on neovide + iosevka custom
            return ' ' .. pick_letter .. ' ' .. buffer.filename .. icon
          end,
        },
      },
    })

    local function my_update_tabline()
      local function my_redraw()
        vim.opt.tabline = cokeline.tabline() -- this is global cokeline
      end
      -- without wrapping with timer, when closing the buffer, its 'tab' is still visible
      vim.fn.timer_start(0, my_redraw)
    end

    -- NOTE: the way we do mappings below is better than overriding the 'cokeline.mappings' functions directly,
    -- since its likely that other things expect to get the references to the original functions
    remap('n', '<Leader>b', function()
      -- temporarity restore the original function, since the code inside calls :redrawtabline
      vim.opt.tabline = '%!v:lua.cokeline.tabline()'
      mappings.pick('focus')
      my_update_tabline()
    end, { desc = 'Jump to buffer' })

    remap('n', '(', function()
      mappings.by_step('focus', -1)
      my_update_tabline()
    end, { desc = 'Go to previous buffer' })

    remap('n', ')', function()
      mappings.by_step('focus', 1)
      my_update_tabline()
    end, { desc = 'Go to next buffer' })

    remap('n', '{', function()
      mappings.by_step('switch', -1)
      my_update_tabline()
    end, { desc = 'Move buffer left' })

    remap('n', '}', function()
      mappings.by_step('switch', 1)
      my_update_tabline()
    end, { desc = 'Move buffer right' })

    vim.api.nvim_create_autocmd({
      'BufAdd',
      'BufDelete',
      'BufEnter',
      'BufFilePost',
      'BufLeave',
      'BufModifiedSet',
      'BufNew',
      'BufNewFile',
      'BufReadPost',
      'BufWipeout',
      'DirChanged',
      'TabClosed',
      'TabEnter',
      'TabNew',
      'UIEnter',
      'VimResized',
      'WinEnter',
    }, {
      desc = 'My: manually update tabline',
      group = vim.api.nvim_create_augroup('my-update-tabline', {}),
      callback = my_update_tabline,
    })
  end,
}
