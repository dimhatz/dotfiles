-- path processing taken from original neodev plugin (now deprecated)
local normalize_filename = require('my-helpers').normalize_filename
local PATHSTRICT = true

local function get_libs()
  local paths = {}

  local function add(lib)
    ---@diagnostic disable-next-line: param-type-mismatch
    for _, p in ipairs(vim.fn.expand(lib .. '/lua', false, true)) do
      local real_path = vim.uv.fs_realpath(p)
      if real_path then
        if PATHSTRICT then
          table.insert(paths, real_path)
        else
          table.insert(paths, vim.fn.fnamemodify(real_path, ':h'))
        end
      end
    end
  end

  add('$VIMRUNTIME')

  ---@type table<string, boolean>
  for _, site in pairs(vim.split(vim.o.packpath, ',')) do
    add(site .. '/pack/*/opt/*')
    add(site .. '/pack/*/start/*')
  end

  for _, plugin in ipairs(require('lazy').plugins()) do
    add(plugin.dir)
  end

  add(vim.fn.getcwd())

  paths = vim.tbl_map(normalize_filename, paths)

  table.insert(paths, '${3rd}/luv/library')

  return paths
end

local function get_path(settings)
  if PATHSTRICT then
    return { '?.lua', '?/init.lua' }
  end

  settings = settings or {}
  local runtime = settings.Lua and settings.Lua.runtime or {}
  local meta = runtime.meta or '${version} ${language} ${encoding}'
  meta = meta:gsub('%${version}', runtime.version or 'LuaJIT')
  meta = meta:gsub('%${language}', 'en-us')
  meta = meta:gsub('%${encoding}', runtime.fileEncoding or 'utf8')

  return {
    -- paths for builtin libraries
    ('meta/%s/?.lua'):format(meta),
    ('meta/%s/?/init.lua'):format(meta),
    -- paths for meta/3rd libraries
    'library/?.lua',
    'library/?/init.lua',
    -- Neovim lua files, config and plugins
    'lua/?.lua',
    'lua/?/init.lua',
  }
end

-- generate a .luarc.json file at each vim start
vim.api.nvim_create_autocmd('User', {
  group = vim.api.nvim_create_augroup('my-gen-luarc-after-lazy', { clear = true }),
  pattern = 'LazyVimStarted',
  callback = function()
    local normalized_cwd = vim.fn.getcwd() -- will also be added to libs (and normalized)
    if not vim.uv.fs_stat(normalize_filename(normalized_cwd) .. '/generate_luarc_here') then
      return
    end

    local json = {
      runtime = {
        path = get_path(),
        pathStrict = PATHSTRICT,
        version = 'LuaJIT',
      },
      workspace = {
        library = get_libs(),
      },
    }

    vim.fn.writefile({ vim.json.encode(json) }, '.luarc.json', 's')
  end,
})
