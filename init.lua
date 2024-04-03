if vim.g.vscode then
    -- VSCode extension
    local vscode = require('vscode-neovim')
    vscode.notify('world')
elseif vim.g.neovide then
	vim.o.guifont = "Source Code Pro:h14"
	vim.g.neovide_refresh_rate = 60
    vim.g.neovide_cursor_animate_in_insert_mode = false
else
    -- ordinary Neovim
end
