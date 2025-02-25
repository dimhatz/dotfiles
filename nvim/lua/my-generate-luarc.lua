-- path processing taken from original neodev plugin (now deprecated)
local normalize_filename = require('my-helpers').normalize_filename
local PATHSTRICT = true

---@param additional_libs? string[]
local function get_libs(additional_libs)
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

  additional_libs = additional_libs or {}

  for _, additional_lib in ipairs(additional_libs) do
    add(additional_lib)
  end

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
    local generate_here_path = normalize_filename(vim.fn.getcwd()) .. '/generate_luarc_here'
    if not vim.uv.fs_stat(generate_here_path) then
      return
    end

    local contents = vim.fn.readfile(generate_here_path)[1] or ''
    local additional_libs = {} ---@type string[]
    local decode_ok, decode_res = pcall(vim.json.decode, contents)
    if not decode_ok then
      vim.notify('My generate .luarc.json: could not decode json from generate_luarc_here', vim.log.levels.ERROR)
    else
      additional_libs = decode_res.additional_libs or {}
      vim.print('My generate .luarc.json: additional libs: ' .. vim.inspect(decode_res.additional_libs))
    end

    local final_json = {
      -- To confirm correctness: open with vscode, it will check against this schema and underline bad fields
      ['$schema'] = 'https://raw.githubusercontent.com/LuaLS/vscode-lua/master/setting/schema.json',
      ['runtime.path'] = get_path(),
      ['runtime.pathStrict'] = PATHSTRICT,
      ['runtime.version'] = 'LuaJIT',
      ['workspace.library'] = get_libs(additional_libs),
    }

    vim.fn.writefile({ vim.json.encode(final_json) }, '.luarc.json', 's')
    vim.print('My generate .luarc.json: Written .luarc.json')
  end,
})
