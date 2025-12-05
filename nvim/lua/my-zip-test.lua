-- TODO: when opening, set noundo, restore view if possible, disable autoformatting
-- TODO: make sure we dont save plain text, throw error if there is only one line before saving.
-- TODO: after saving file, re-read it from disk and verify it was successfully written and no formatting
-- occured, compare with orig_text_backup

local logging_enabled = true --- logging
--- wrapper around vim.print()
local function log(...)
  if logging_enabled then
    vim.print(...)
  end
end

--- @param message string
local function nerr(message)
  vim.notify(message, vim.log.levels.ERROR)
end

--- @param message string
local function nwarn(message)
  vim.notify(message, vim.log.levels.WARN)
end

---@class FileInfo
---@field pw string
---@field orig_text_backup string
----- NOT taking into account that the file may be open in many windows and have many views
---@field view vim.fn.winsaveview.ret? --- nil on first opening / after saving, to be overwritten just before writing and used after writing.
---@field error string | false

---@type table<string, FileInfo>
-- table<path, file_info>, remembers passes when saving to avoid asking user for prompt again
-- if file info is missing, it means that it is newly created.
local files = {}

---@param cmd string[]
---@param stdin string
---@param result_to_verify string?
---@return string
---Executes system command, feeding string into stdin. Returns stdout as string.
---Throws on failure (use pcall). Times out after 300ms.
local function exec(cmd, stdin, result_to_verify)
  local result = vim.system(cmd, { stdin = stdin }):wait(300)
  if result.code ~= 0 then
    if result.code == 124 then
      vim.print('My zip: timeout while executing command: ', table.concat(cmd, ' '))
    else
      vim.print('My zip: error while executing command: ', table.concat(cmd, ' '))
    end
    vim.print(result)
    error('My zip exec error')
  end
  local stdout = result.stdout
  if result_to_verify ~= nil then
    if result_to_verify ~= stdout then
      vim.print('My zip: error while verifying the output of command: ', table.concat(cmd, ' '))
      vim.print('Got: ', stdout, 'Expected: ', result_to_verify)
      error('My zip verification error')
    end
  end
  return result.stdout
end

--- Throws on failure (use pcall)
local function compress(plaintext, verification_str)
  local compress_cmd = { 'gzip', '--stdout', '--best' }
  local compressed_string = exec(compress_cmd, plaintext, verification_str)
  -- vim.print(compressed_string)
  return compressed_string
end

--- Throws on failure (use pcall)
local function encrypt(compressed_str, pw, verification_str)
  -- NOTE: when using salt (default openssl behavior), encrypting the same string results in a different
  -- encrypted string every time. This matters when verifying the correctness of the encryption.

  local encrypt_cmd = { 'openssl', 'enc', '-aes-256-cbc', '-salt', '-pbkdf2', '-A', '-base64', '-pass' }
  -- local encrypt_cmd = { 'openssl', 'enc', '-aes-256-cbc', '-nosalt', '-pbkdf2', '-A', '-base64', '-pass' }
  table.insert(encrypt_cmd, 'pass:' .. pw)
  local encrypted_str = exec(encrypt_cmd, compressed_str, verification_str)
  -- vim.print(encrypted_string)
  return encrypted_str
end

--- Throws on failure (use pcall)
local function decrypt(encrypted_str, pw, verification_str)
  -- openssl enc -d -aes-256-cbc -salt -pbkdf2 -pass pass:MyPassword
  -- local decrypt_cmd = { 'openssl', 'enc', '-d', '-aes-256-cbc', '-salt', '-pbkdf2', '-pass' }
  local decrypt_cmd = { 'openssl', 'enc', '-d', '-aes-256-cbc', '-salt', '-pbkdf2', '-A', '-base64', '-pass' }
  -- local decrypt_cmd = { 'openssl', 'enc', '-d', '-aes-256-cbc', '-nosalt', '-pbkdf2', '-A', '-base64', '-pass' }
  table.insert(decrypt_cmd, 'pass:' .. pw)

  local decrypted_str = exec(decrypt_cmd, encrypted_str, verification_str)
  -- vim.print(decrypted_string)
  return decrypted_str
end

--- Throws on failure (use pcall)
local function decompress(compressed_str, verification_str)
  local decompress_cmd = { 'gzip', '--stdout', '--decompress' }
  local decompressed_str = exec(decompress_cmd, compressed_str, verification_str)
  -- vim.print(decompressed_string)
  return decompressed_str
end

---@return string?
---@param encrypted_str string? if nil is given, will just prompt for a non-blank pass
local function ask_for_pass(encrypted_str)
  local times_asked = 1
  local pass = ''
  while times_asked <= 5 do
    -- TODO: use another function that reads chars, until <CR> is given. Display the same message,
    -- replacing input with * (so that pass is not visible on screen).
    pass = vim.fn.input('Enter pass: ')
    if pass == '' then
      goto continue
    elseif encrypted_str then
      -- non-blank pass and encrypted string
      local ok, _ = pcall(decrypt, encrypted_str, pass)
      if ok then
        return pass
      end
    else
      -- non-blank pass but no encrypted string
      return pass
    end
    ::continue::
    times_asked = times_asked + 1
  end
  return nil
end

---@return string
local function get_current_buffer_text()
  -- defensively save view, to restore cursor and scroll pos after gg0, needed when doing just verification
  -- of e.g. pasted text.
  local view = vim.fn.winsaveview()
  local reg_z_backup = vim.fn.getreg('z')

  -- go to the very beginning and copy all the text into register z.
  -- Notes:
  -- noautocmd to avoid triggering our YankTextPost autocmd
  -- :exe to be able to trigger <C-End> motion
  -- vim.cmd('noautocmd normal! gg0"zyG') -- will not work since yG a linewise motion (adds extra newline)
  -- <C-End> is needed, thus :exe command, to make it work
  vim.cmd([[exe "noautocmd normal! gg0\"zy\<C-End>"]])

  local plain_orig = vim.fn.getreg('z')
  vim.fn.setreg('z', reg_z_backup) -- restore reg z now
  vim.fn.winrestview(view)
  return plain_orig
  -- ALTERNATIVE:
  -- concatenating with '\n' just in case. When 'binary' is set (in read pre), new lines are unix-style.
  -- local plain_orig = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')
end

---@param text string
--- Will move cursor to topmost line, leftmost col (col 1)
--- Param text must end with "\n" that will be removed before pasting. "zyG"
local function set_current_buffer_text(text)
  log('set_current_buffer_text(): setting to: ', vim.inspect(text))
  local reg_z_backup = vim.fn.getreg('z')
  vim.fn.setreg('z', text, 'c')

  -- delete text into black hole and set lines, not using visual to avoid breaking gv, our visual repeat etc
  vim.cmd('undojoin | noautocmd normal! gg0"_dG"zp')
  vim.fn.setreg('z', reg_z_backup) -- restore reg z now

  -- ALTERNATIVE:
  -- needs bo.binary = true to make sure unix-style line endings are used for consistency
  -- local plain_lines = vim.split(plain_decompressed, '\n', { plain = true })
  -- vim.api.nvim_buf_set_lines(0, 0, -1, false, plain_lines)

  -- ALTERNATIVE2 (not tested):
  -- vim.cmd('undojoin | lua require("my-zip-test").helper_fn()')
end

local function my_zip_read_pre()
  log('On read pre ' .. vim.api.nvim_buf_get_name(0))
  vim.bo.binary = true
  vim.bo.undofile = false
  vim.bo.swapfile = false
end

local function my_zip_read_post()
  log('On read post ' .. vim.api.nvim_buf_get_name(0))
  -- TODO: decide whether to use nvim_buf_get_lines / set_lines or our register-based workaround
  -- or maybe keep both (just for the sake of verification)

  local file_path = vim.api.nvim_buf_get_name(0)
  files[file_path] = { pw = '', orig_text_backup = '', error = 'Error during initialization on read post' }

  local encrypted_orig = get_current_buffer_text()
  -- TODO: ask for pass in a loop, if blank pass is provided, immediately close file
  -- also check for whitespace chars, like \t etc
  -- local user_pw = vim.fn.input('Enter pass:') ---@type string
  local pass = ask_for_pass(encrypted_orig)
  if pass == nil then
    nerr('Incorrect pass, opening (as is, in binary mode)!')
    files[file_path].error = 'Bad pass'
    return
  end
  -- vim.print(decr)
  local decrypted_compressed = decrypt(encrypted_orig, pass)
  local plain_decompressed = decompress(decrypted_compressed)
  -- vim.print(plain)

  -- -- verification, will throw on error, only works when encrypting without salt
  -- compress(plain_decompressed, decrypted_compressed)
  -- encrypt(decrypted_compressed, pass, encrypted_orig)

  files[file_path] = { pw = pass, orig_text_backup = plain_decompressed, error = false }

  set_current_buffer_text(plain_decompressed)

  -- verify the buffer text, using nvim_buf_get_lines() as an alternative method of verification
  local curr_lines = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')
  if curr_lines ~= plain_decompressed then
    nerr('Text in buffer does not match the decrypted')
  end

  vim.bo.binary = false
end

local function my_zip_write_pre()
  log('On write pre ' .. vim.api.nvim_buf_get_name(0))
  local file_path = vim.api.nvim_buf_get_name(0)
  if files[file_path].error then
    local err = 'Will not change text on save. Error was encountered: ' .. files[file_path].error
    vim.print(files[file_path])
    nerr(err)
    return
  end

  vim.bo.binary = true

  if file_path == '' then
    local err = 'No filename for the buffer. Use :enew new_name123.gzipddd, then save.'
    nerr(err)
    return
  end

  local plain_orig = get_current_buffer_text()
  files[file_path].orig_text_backup = plain_orig

  files[file_path].view = vim.fn.winsaveview()

  local compressed = compress(plain_orig)
  local pw = files[file_path].pw
  if pw == '' then
    nwarn('Empty pass found. This should never happen.')
    return
  end
  local encrypted = encrypt(compressed, pw)

  log('verification 1: does encrypted / zipped match decrypted / unzipped?')
  decrypt(encrypted, pw, compressed)
  decompress(compressed, plain_orig)

  set_current_buffer_text(encrypted)

  log('verification 2: does the pasted text matches the encrypted?')
  local buffer_text_encrypted = get_current_buffer_text()

  if buffer_text_encrypted ~= encrypted then
    vim.print('pasted (current):', vim.inspect(buffer_text_encrypted))
    vim.print('encrypted:', vim.inspect(encrypted))
    error('Pasted does not match encrypted')
  end
end

local function my_zip_write_post()
  log('On write post ' .. vim.api.nvim_buf_get_name(0))
  local buffer_text = get_current_buffer_text()
  local file_path = vim.api.nvim_buf_get_name(0)
  local decrypted_compressed = decrypt(buffer_text, files[file_path].pw)
  -- will also verify that we match the original
  local decompressed = decompress(decrypted_compressed, files[file_path].orig_text_backup)
  set_current_buffer_text(decompressed)

  -- Alternative to "undojoin | " is to perform non-reversible undo, but in this case we will not be
  -- replacing the buffer text with the decrypted-decompressed one, that allows us to visually verify if
  -- smth went wrong. TODO: see if undo! is a better option.
  -- vim.cmd('undo!')
  -- vim.cmd('undo!')

  -- verify the text replacement in the buffer matches the original
  buffer_text = get_current_buffer_text()
  if buffer_text ~= files[file_path].orig_text_backup then
    error('My zip: the buffer text does not match the original')
  end

  vim.fn.winrestview(files[file_path].view)
  vim.bo.binary = false
  vim.bo.modified = false
end

local function my_zip_buf_enter()
  -- also triggers on new file
  log('On buf enter ' .. vim.api.nvim_buf_get_name(0))
  local file_path = vim.api.nvim_buf_get_name(0)
  if files[file_path] then
    log('The file is already in our dict')
    return
  end
  vim.bo.undofile = false
  vim.bo.swapfile = false
  local input_pw = ask_for_pass()
  -- lua ternary using and / or is weird: do not use "and false" or "and nil" -> will not short-circuit,
  -- will not evaluate to false / nil, but will evaluate to whatever follows the "or"
  files[file_path] = { pw = input_pw or '', orig_text_backup = '', view = vim.fn.winsaveview(), error = not input_pw and 'Bad pass during buf enter' or false }
  _ = not input_pw and vim.notify_once('Buf enter: Bad pass for: ' .. file_path, vim.log.levels.ERROR)
  -- TODO: decrypt, decompress and set text buffer
end

local function my_zip_buf_delete(args)
  -- WARNING: do not use vim.api.nvim_buf_get_name(0) here, it returns the next buffer's path
  log('On buf delete ' .. vim.api.nvim_buf_get_name(args.buf))
  local file_path = vim.api.nvim_buf_get_name(args.buf)
  if not files[file_path] then
    vim.print('file path: ' .. file_path, 'dict: ', files)
    nerr('Expected file to be registered in our dict. This should never happen.')
  end
  files[file_path] = nil
end

function My_zip_change_pw()
  local input_pw = ask_for_pass()
  local file_path = vim.api.nvim_buf_get_name(0)
  if not files[file_path] then
    error('Expected file to be registered in our dict. This should never happen.')
  end
  if not input_pw then
    error('Got bad pass, when changing pass')
  end
  files[file_path].pw = input_pw
end

function My_zip_test_commands_correctness()
  local orig = 'haie'
  local compressed = compress(orig)
  vim.print('compressed: ', compressed)
  compress(orig, compressed)
  local test_pass = 'test_pass'
  local encrypted = encrypt(compressed, test_pass)
  vim.print('encrypted: ', encrypted)

  -- -- encrypting the same string will only have the same result when encrypting without salt
  -- encrypt(compressed, test_pass, encrypted)

  local decrypted = decrypt(encrypted, test_pass, compressed)
  decompress(decrypted, orig)
  vim.print('all checks OK')
end

local augroup = vim.api.nvim_create_augroup('my-zip', {})

vim.api.nvim_create_autocmd({
  'BufReadPre',
}, {
  desc = 'My zip test',
  pattern = '*.gzipddd',
  group = augroup,
  callback = my_zip_read_pre,
})

vim.api.nvim_create_autocmd({
  'BufReadPost',
}, {
  desc = 'My zip test',
  pattern = '*.gzipddd',
  group = augroup,
  callback = my_zip_read_post,
})

vim.api.nvim_create_autocmd({
  'BufWritePre',
}, {
  desc = 'My zip test',
  pattern = '*.gzipddd',
  group = augroup,
  callback = my_zip_write_pre,
})

vim.api.nvim_create_autocmd({
  'BufWritePost',
}, {
  desc = 'My zip test',
  pattern = '*.gzipddd',
  group = augroup,
  callback = my_zip_write_post,
})

vim.api.nvim_create_autocmd({
  'BufEnter',
}, {
  desc = 'My zip test',
  pattern = '*.gzipddd',
  group = augroup,
  callback = my_zip_buf_enter,
})

vim.api.nvim_create_autocmd({
  'BufDelete',
}, {
  desc = 'My zip test',
  pattern = '*.gzipddd',
  group = augroup,
  callback = my_zip_buf_delete,
})
