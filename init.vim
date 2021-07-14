" location in windows for nvim is C:\Users\dim\AppData\Local\nvim\init.vim

" sync with "CLIPBOARD" OS clipboard, uses "+ register
set clipboard=unnamedplus

nnoremap ; :
nnoremap : ;

nnoremap <Space> <Nop>
xnoremap <Space> <Nop>
onoremap <Space> <Nop>
let mapleader = "\<Space>"

" Reselect pasted text linewise, ( `[ is jump to beginning of changed/yanked )
nnoremap <Leader>v `[V`]
nnoremap <silent> <ESC> :nohlsearch<CR><ESC>
closeParameterHints

" Swap V and CTRL-v
nnoremap <C-V>   V
xnoremap <C-V>   V
nnoremap V   <C-V>
xnoremap V   <C-V>

" Paste over smth in visual does not overwrite the main '+' register.
xnoremap <silent> p p:let @+=@0<CR>
" TODO: detect when "dd"-ing empty/whitespace lines and stop overwriting "+"

" x will always delete to black hole
nnoremap x "_x
xnoremap x "_x

" X deletes to black hole till end of line
nnoremap X "_D

" Y yanks till end of line, instead of whole line
nnoremap Y y$


" nothing is copied into buffers when changing text
nnoremap <silent> c "_c

if exists('g:vscode')
    " ---------------------- vscode-specific stuff goes here

    " when sending <C-s> from vscode, neovim receives the command,
    " escapes and saves, but it moves the cursor one word back, possibly desyncing with nvim instance.
    " not using this for now. TODO: try again later.
    " inoremap <C-S> <ESC>:Write<CR>


    " using vscode's undo/redo, since the 'dirty file' dot in vscode does not go away when undoing till the last saved state
    " vscode API update is required: https://github.com/asvetliakov/vscode-neovim/issues/247
    " also, this should prevent any potential desyncs due to undo
    nnoremap <silent> u :<C-u>call VSCodeNotify('undo')<CR>
    nnoremap <silent> <C-r> :<C-u>call VSCodeNotify('redo')<CR>


	" gr for Go to References
    nnoremap <silent> gr :<C-u>call VSCodeNotify('editor.action.goToReferences')<CR>

    nnoremap <silent> ( :<C-u>call VSCodeNotify('workbench.action.previousEditor')<CR>
    nnoremap <silent> ) :<C-u>call VSCodeNotify('workbench.action.nextEditor')<CR>


else
    " ---------------------- neovim-specific stuff goes here
    inoremap <C-S> <ESC>:write<CR>
endif
