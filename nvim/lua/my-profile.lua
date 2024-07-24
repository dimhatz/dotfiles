local remap = require('my-helpers').remap

return {
  'stevearc/profile.nvim',
  config = function()
    require('profile').instrument_autocmds()
    require('profile').instrument('*')

    local function toggle_profile()
      local prof = require('profile')
      if prof.is_recording() then
        prof.stop()
        vim.ui.input({ prompt = 'Save profile to:', completion = 'file', default = 'profile.json' }, function(filename)
          if filename then
            prof.export(filename)
            vim.notify(string.format('Wrote %s', filename))
          end
        end)
      else
        prof.start('*')
      end
    end
    remap('', '<C-F1>', toggle_profile, { desc = 'Start / stop profiler' })
  end,
}
