" -------- unused plugins -------------------------------------------
"Plug 'dimxdim/jellybat'

" prev vim-airline/vim-airline commit a914cfb75438c36eefd2d7ee73da5196b0b0c2da
Plug 'vim-airline/vim-airline', {'commit': '72ca1c344fc48f8a5dec7e8c4b75da0436176338'}

" prev vim-airline/vim-airline-themes commit
Plug 'vim-airline/vim-airline-themes', {'commit': '7865fd8ba435edd01ff7b59de06a9be73e01950d'}

" " Alternative to bufferline mgee/lightline-bufferline, for use with
" lightline
" " Plug 'taohex/lightline-buffer'

" Plug 'flazz/vim-colorschemes'
" Plug 'NLKNguyen/papercolor-theme'

" Needs lua53.dll from http://lua-users.org/wiki/LuaBinaries (64bit like my vim) in the same dir as gvim.exe
" alternative source for lua binaries, mentioned on github vim distribution:
" http://luabinaries.sourceforge.net/download.html
" (also according to shougo/denite python can also be added this way from
" official site -> choose python embeddable and copy all zip contents to vim's
" install dir)
Plug 'Shougo/neocomplete', {'commit': 'd8caad4fc14fc1be5272bf6ebc12048212d67d2c'}
" ------------------------------------------------------------
" set lazyredraw
" May help with scrolling, may worsen flicker of completion popup menu
" Also may cause glitch with ycm when typing very fast, where ycm will display
" identifier (words from file) suggestions, but as if 2 last letters were not
" typed. Example: set lazyredraw and type very fast "w e r e r" (without
" spaces), then ^w until " incorrect suggestion appears.
" Setting power options to "Power saver mode" in Windows helps expose the bug.
" Also check:http://eduncan911.com/software/fix-slow-scrolling-in-vim-and-neovim.html
" set lazyredraw
" ------------------------------------------------------------------------------

" TODO migrate to pathogen and version control using git ("git submodule add" etc)
" iff there is a way in pathogen to ensure the plugin loading order (maybe
" prepend plugin dirs with numbers like 01_vim_airline/ etc and then clone
" into them and check the order in runtimepath).

" ------------------------------------------------------------------------------
" Version-controlled installation of vim-plug, that will be self-updatable
" manually later. On windows console:
" cd %USERPROFILE%
" mkdir .vim\autoload .vim\plugged
" put the following file into .vim/autoload (linebreakes will be unix-
" style, does it matter?)
" https://github.com/junegunn/vim-plug/raw/449b4f1ed6084f81a1d0c2c1136cd242ec938625/plug.vim
" (commit at SHA 449b4f1ed6084f81a1d0c2c1136cd242ec938625)
" Better to git clone, as it will auto-adjust linebreaks to-from win-unix:
" mkdir vim-plug-temp && cd vim-plug-temp
" git clone https://github.com/junegunn/vim-plug.git .\
" git reset --hard 449b4f1ed6084f81a1d0c2c1136cd242ec938625
" copy plug.vim ..\.vim\autoload
" Restart vim and ":PlugInstall youcomplete" first, then ":PlugInstall" for
" the rest of plugins. Done.
" -------------- vim-plug
" the two below are auto-called by vim-plug, leaving here for future reference
syntax enable
filetype plugin indent on

" (a better?) alternative to "syntax on"
if !exists("g:syntax_on")
	syntax enable
endif
" source: https://stackoverflow.com/questions/33380451/is-there-a-difference-between-syntax-on-and-syntax-enable-in-vimscript
" current setting after plug#end:
syntax on           " syntax enable syntax processing, *syntax on* overrides with defaults!
" ------------------------------------------------------------------------------

" vimproc build/install instructions
" On win10 to install win 7.1 sdk:
" https://stackoverflow.com/questions/32091593/cannot-install-windows-sdk-7-1-on-windows-10
" 7.1 sdk is needed for win32.mak file, see:
" https://github.com/Shougo/vimproc.vim/issues/58
" To build to go Start->Visual Studio->x64 native tools command prompt
" so that it includes all the needed paths. For win32.mak to be found:
" $ SET INCLUDE=%INCLUDE%;C:\Program Files\Microsoft SDKs\Windows\v7.1\Include
"              (on 64bit) C:\Program Files\Microsoft SDKs\Windows\v7.1\Include
" $ nmake -f make_msvc.mak nodebug=1
" To check whether its working :echo vimproc#system('dir')
" ------------------------------------------------------------------------------

" YouCompleteMe should be updated on its own (so that it does not timeout) using:
" :PlugUpdate YouCompleteMe
" Neovim: check with :CheckHealth if python3 provider is correct.
" also check :messages to see whether ycm complains
" ycm -> was installed by .\install.py --clang-completer --js-completer
" Plug 'Valloric/YouCompleteMe', {'commit': 'bade99f5e9c5ba2f848cffb2d1a905e85d3ddb05'}
" ------------------------------------------------------------------------------

" gvimfullscreen_win32: uses dll, needs to be mapped like:
if has('win64')
	nnoremap <F11> <Esc>:call libcallnr(expand('$HOME\.vim\plugged\gvimfullscreen_win32\gvimfullscreen_64.dll'), "ToggleFullScreen", 0)<CR>
elseif has('win32')
	nnoremap <F11> <Esc>:call libcallnr(expand('$HOME\.vim\plugged\gvimfullscreen_win32\gvimfullscreen.dll'), "ToggleFullScreen", 0)<CR>
endif
" " Also fullscreen functionality (vim-shell + vim-misc, should work on unix too):
" vim-misc is required by vim-shell
" Plug 'xolox/vim-misc', {'commit': '3e6b8fb6f03f13434543ce1f5d24f6a5d3f34f0b'}
" vim-shell, to be used for :Fullscreen command etc
" Plug 'xolox/vim-shell', {'commit': 'c19945c6cb08db8d17b4815239e2e7e0051fb33c'}
" ------------------------------------------------------------------------------

" tern-js for javascript (unneeded with ycm, as ycm already includes it?)
" Plug 'ternjs/tern_for_vim', {'commit': 'ae42c69ada7243fe4801fce3b916bbc2f40ac4ac'}

" javacomplete2
" Plug 'artur-shaik/vim-javacomplete2', {'commit': 'ae351ecf333e77873fa4682b4d4b05f077047bc4'}
" ------------------------------------------------------------------------------

" for powerline
" set runtimepath+=$HOME/.vim/plugged/powerline/powerline/bindings/vim
" ------------------------------------------------------------------------------

" TODO investigate eclim integration with airline bug:
" when error occurs it is not shown in airline upon save, but upon next
" modification after save. Also goes away (after error is fixed) not upon
" saving but after saving and modifying.
" ------------------------------------------------------------------------------

" directx renderer will also render font shapes differently.
" to test, :h airline, start changing rop, check "i" shapes, some may render the dot too close, some "l" may be rendered as |.
" also, may affect performance (slower scrolling),
" try adding more than directx if rendering is ugly - in my w10_x64 made no difference
" set rop=type:directx,gamma:1.0,contrast:0.5,level:1,geom:1,renmode:4,taamode:1 -recom. by airline
" set renderoptions=type:directx,level:0.75,gamma:1.25,contrast:0.25,geom:1,renmode:5,taamode:1
" ------------------------------------------------------------------------------

" Old guicursor settings:
	"set guicursor=n-v-c:blinkon0-block-Cursor/lCursor,ve:ver35-Cursor,o:hor50-Cursor,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor,sm:block-Cursor-blinkwait175-blinkoff150-blinkon175 "dont blink
	"let &guicursor = substitute(&guicursor, 'n-v-c:', '&blinkon0-', '')
	"set guicursor=
	" set lines=999 columns=9999  " open maximized (not always works)
" ------------------------------------------------------------------------------

" Space is the new leader
" another option is "map <Space> <Leader>" but will not trigger double leader
" aka <Leader><Leader> mappings
" let mapleader = "\<Space>" if let mapleader = " " doesnt work
" also if remapped leader is continuously pressed, next leader presses will
" not be triggered until modes are changed (easymotion probably is culprit)
"let mapleader = " "
" ------------------------------------------------------------------------------

" Paste:
" If you visually select something and hit paste
" that thing gets yanked into your buffer. This
" generally is annoying when you're copying one item
" and repeatedly pasting it. This changes the paste
" command in visual mode so that it doesn't overwrite
" whatever is in your paste buffer.
" xnoremap p "_dP doesnt work as expected when pasting upon the last line (when using linewise)
" Solution: since regular p (non-mapped) works as expected, all we need to do
" is just temporarily store what is in the + register, then write it back,
" because it will be replaced by regular p.
" Register "0 stores the value to be pasted even after pasting.
xnoremap <silent> p p:let @+=@0<CR>

" TODO activate paste mode before pasting (good for terminals)
" check whether they handle ^H and ^h as <BS>, also :h paste
" if !has("gui_running")
" 	xnoremap <silent> p :<C-U>set paste<CR>gvp:let @+=@0<CR>:set nopaste<CR>
" 	nnoremap <silent> p :set paste<CR>p:set nopaste<CR>
" endif
" Test if this is needed first (some terminals may be smart enough, also when
" using the "+" register the regular paste may be ok as it is, but not for other registers)

" we can also indent the pasted text - a bit twitchy/flashing due to reselection
"xnoremap p "_dPV`]=
" that's why we can use =`]
" (`] marker-motion == jump to end to previously changed/yanked text)

" xnoremap p "_dP=`]
" nnoremap p p=`]
" ------------------------------------------------------------------------------
" Stop highlighting matching search pattern and any vim-exchange selections pressing <ESC>
" BEGIN_ESCAPE_WORKAROUND
	" In terminal <esc>smth must be mapped in order to trigger timeout.
	" Only then it will work. Else numbers shown on startup in terminal.
	" also, rapid pressing <esc><F*> will result in weird behavior, such
	" as entering insert mode and writing S for <esc><F4>.
	" Triple esc mapping prevents it.
	" At the end adding :execute "normal \<Plug>(ExchangeClear)"<CR>
	" to cancel any vim-exchange markings-highlights.
	" If there will be no further remaps of vim-exchange's cxc then ending
	" :call feedkeys("cxc")<CR>
	" should work too.
	" Also :call feedkeys("\<Plug>(ExchangeClear)")<CR> should work too.
	" Lastly, <Plug>(ExchangeClear) wont work without parens () around
	" ExchangeClear, they might be part of the name (?)
	" How to call <Plugs>: https://stackoverflow.com/questions/8862290/vims-plug-based-mappings-dont-work-with-normal-command
	" Also works:
		" nnoremap <silent> <ESC> :nohlsearch<CR><ESC>:call feedkeys("\<Plug>(ExchangeClear)")<CR>
	" My original mappings (before adding ExchangeClear):
		" nnoremap <silent> <ESC> :nohlsearch<CR><ESC>
		" nnoremap <silent> <ESC><ESC> :nohlsearch<CR><ESC>
		" nnoremap <silent> <ESC><ESC><ESC> :nohlsearch<CR><ESC>

" Stop highlighting matching search pattern and any vim-exchange selections pressing <ESC>
" BEGIN_ESCAPE_WORKAROUND
	" In terminal <esc>smth must be mapped in order to trigger timeout.
	" Only then it will work. Else numbers shown on startup in terminal.
	" also, rapid pressing <esc><F*> will result in weird behavior, such
	" as entering insert mode and writing S for <esc><F4>.
	" Triple esc mapping prevents it.
	" At the end adding :execute "normal \<Plug>(ExchangeClear)"<CR>
	" to cancel any vim-exchange markings-highlights.
	" If there will be no further remaps of vim-exchange's cxc then ending
	" :call feedkeys("cxc")<CR>
	" should work too.
	" Also :call feedkeys("\<Plug>(ExchangeClear)")<CR> should work too.
	" Lastly, <Plug>(ExchangeClear) wont work without parens () around
	" ExchangeClear, they might be part of the name (?)
	" How to call <Plugs>: https://stackoverflow.com/questions/8862290/vims-plug-based-mappings-dont-work-with-normal-command
	" Also works:
		" nnoremap <silent> <ESC> :nohlsearch<CR><ESC>:call feedkeys("\<Plug>(ExchangeClear)")<CR>
	" My original mappings (before adding ExchangeClear):
		" nnoremap <silent> <ESC> :nohlsearch<CR><ESC>
		" nnoremap <silent> <ESC><ESC> :nohlsearch<CR><ESC>
		" nnoremap <silent> <ESC><ESC><ESC> :nohlsearch<CR><ESC>

" <ESC> clears search highlights and exhange marking highlights.
" GUI doesnt need <ESC><ESC> workaround, so lets not add the its delay.
if has('gui_running')
	nnoremap <silent> <ESC> :nohlsearch<CR><ESC>:execute "normal \<Plug>(ExchangeClear)"<CR>
	" the <ESC> mapping unmaps cxc for some reason, so redo the mapping
	" nmap cxc <Plug>(ExchangeClear)
	nnoremap <silent> cxc :execute "normal \<Plug>(ExchangeClear)"<CR>
	" feedkeys("cxc") works without breaking norm cxc, not sure about
	" performance though, feels like the same, keeping for future ref:
	" nnoremap <silent> <ESC> :nohlsearch<CR><ESC>:call feedkeys("cxc")<CR>
else
	nnoremap <silent> <ESC> :nohlsearch<CR><ESC>:execute "normal \<Plug>(ExchangeClear)"<CR>
	nnoremap <silent> <ESC><ESC> :nohlsearch<CR><ESC>:execute "normal \<Plug>(ExchangeClear)"<CR>
	nnoremap <silent> <ESC><ESC><ESC> :nohlsearch<CR><ESC>:execute "normal \<Plug>(ExchangeClear)"<CR>
	" nmap cxc <Plug>(ExchangeClear)
	nnoremap <silent> cxc :execute "normal \<Plug>(ExchangeClear)"<CR>
endif
" END_ESCAPE_WORKAROUND
" ------------------------------------------------------------------------------

" On windows with conemu:
" add this to conemu envir.variables script setting so that powerline symbols
" appear correctly.
" "#" stands for comment
" set ConEmuDefaultCp=65001
" # chcp 65001
" # chcp utf8
if &term=~'win32' && (has('win32') || has('win64')) && !has('gui_running') && !has('nvim') && exists('$ConEmuANSI')
	set term=xterm
	set t_Co=256
	let &t_AB="\e[48;5;%dm"
	let &t_AF="\e[38;5;%dm"
	" set termguicolors
	" fix <BS> on conemu
	inoremap <Char-0x07F> <BS>
	nnoremap <Char-0x07F> <BS>
endif

" " nvim on conemu, not working: colors messed up, airline copied multiple
" times
" if &term=~'win32' && (has('win32') || has('win64')) && !has('gui_running') && has('nvim') && exists('$ConEmuANSI')
" 	set term=xterm
" 	set t_Co=256
" 	let &t_AB="\e[48;5;%dm"
" 	let &t_AF="\e[38;5;%dm"
" 	" set termguicolors
" 	" fix <BS> on conemu
" 	inoremap <Char-0x07F> <BS>
" 	nnoremap <Char-0x07F> <BS>
" endif
" ------------------------------------------------------------------------------

" nvim with GUI
" if has('nvim')
" " 	autocmd VimEnter * execute 'GuiFont! Source Code Pro Medium:h10'
" " could not make it work yet. :messages says GuiFont not an editor command
" " TODO: find a way to check whether neovim is running in gui.
" GuiFont! Source Code Pro Medium:h10
" endif

" The below still dont work, try to test on non-linked main dir and clean
" init.vim
" echom "here"
" if has('nvim') && exists(':GuiFont')
" 	autocmd VimEnter * execute 'GuiFont! Source Code Pro Medium:h10' | echom 'here'
" 	" execute 'GuiFont! Source Code Pro Medium:h10'
" endif

augroup SetFontNeovimDDD
	autocmd!
	autocmd VimEnter * if has('nvim') && exists(':GuiFont') | echom 'here' | execute 'GuiFont! Source Code Pro Medium:h10' | endif
augroup END
" :GuiFont! Source Code Pro Medium:h10
" ------------------------------------------------------------------------------

" "" Special highlight of 81st char in long line, needs to be after colorscheme
" and after special term sequences or else it might be shown not show
" highlight MyColorColumn guifg=#d8d8d8 guibg=#ab4642 guisp=NONE gui=NONE ctermfg=7 ctermbg=1 cterm=NONE
" call matchadd('MyColorColumn', '\%81v', 100)

" to change the color of colorcolumn (better be done with augroup autocmd)
" highlight ColorColumn ctermbg=235 guibg=#2c2d27
" ------------------------------------------------------------------------------

" when colorscheme is changed to solarized family dark
augroup ColorschemeChangeDDD
	autocmd!
	autocmd ColorScheme flattened_dark,solarized8_dark,solarized8_dark_flat
		" \ highlight Pmenu term=bold cterm=underline,bold
		" \ ctermfg=10 ctermbg=8 gui=underline,bold guifg=#586e75
		" \ guibg=#002b36
		" \ | highlight EasyMotionTargetDefault gui=NONE cterm=NONE
		" \ | highlight EasyMotionTarget2FirstDefault gui=NONE cterm=NONE
		" \ | highlight EasyMotionTarget2SecondDefault gui=NONE cterm=NONE
		" \ | AirlineRefresh
	autocmd ColorScheme flattened_light,solarized8_light,solarized8_light_flat
		" \ highlight Pmenu term=bold cterm=underline,bold
		" \ ctermfg=14 ctermbg=15 gui=underline,bold guifg=#93a1a1
		" \ guibg=#fdf6e3
		" \ | highlight EasyMotionTargetDefault gui=NONE cterm=NONE
		" \ | highlight EasyMotionTarget2FirstDefault gui=NONE cterm=NONE
		" \ | highlight EasyMotionTarget2SecondDefault gui=NONE cterm=NONE
		" \ | AirlineRefresh
augroup END

" " remove italics from comments
" highlight Comment gui=NONE cterm=NONE

" ------------------------------------------------------------------------------
" TODO: check this, executes macro over lines
" xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<CR>

" function! ExecuteMacroOverVisualRange()
"   echo "@".getcmdline()
"   execute ":'<,'>normal @".nr2char(getchar())
" endfunction
" ------------------------------------------------------------------------------
" Lightline:
" Only one of {taohex, mgee} sections below should be used.

" ------- Lightline with taohex/lightline-buffer
" let g:lightline = {
" 	\ 'colorscheme': 'solarized',
" 	\ 'tabline': {
" 		\ 'left': [ [ 'bufferinfo' ], [ 'bufferbefore', 'buffercurrent', 'bufferafter' ], ],
" 		\ 'right': [ [ 'close' ], ],
" 		\ },
" 	\ 'component_expand': {
" 		\ 'buffercurrent': 'lightline#buffer#buffercurrent2',
" 		\ },
" 	\ 'component_type': {
" 		\ 'buffercurrent': 'tabsel',
" 		\ },
" 	\ 'component_function': {
" 		\ 'bufferbefore': 'lightline#buffer#bufferbefore',
" 		\ 'bufferafter': 'lightline#buffer#bufferafter',
" 		\ 'bufferinfo': 'lightline#buffer#bufferinfo',
" 		\ },
" 	\ }

" ------------------ Airline
" TODO: set the lightest available options, else remove it.
" makes cursor lag + text flash on new appending/inserting first char - only
" when buffer was unmodified (that is, without [+]).
" do not detect modified, should not produce the above lag on first insert
" TODO: build custom statusline and tabline so that performance is good:
" The performance is currently so bad, that even entering insert causes cursor
" flicker. It's likely not a good idea to use expressions in statusline, as they will be
" evaluated every statusline auto-redraw-update. Better idea is to
" use autocmds to change variables displayed, also to change colors using
" "hi link" to switch using autocmds. Links confirming redraws/calls:
" https://vi.stackexchange.com/questions/7441/display-current-subroutine-subprogram-in-statusline
" http://vim.wikia.com/wiki/Non-native_fileformat_for_your_statusline

" For customization, some places to start are:
" https://github.com/ap/vim-buftabline <-- here first
" http://www.vim.org/scripts/script.php?script_id=1664 <-- buftabs, minimal
" https://github.com/mkitt/tabline.vim <-- only 80 sloc, but shows only tabs
" https://www.reddit.com/r/vim/comments/e19bu/whats_your_status_line/
" https://github.com/tpope/vim-flagship
" https://shapeshed.com/vim-statuslines/
" https://www.blaenkdenum.com/posts/a-simpler-vim-statusline/
" http://got-ravings.blogspot.gr/search/label/statuslines
" https://nkantar.com/blog/my-vim-statusline/
" https://gabri.me/blog/diy-vim-statusline/
" http://got-ravings.blogspot.gr/search/label/statuslines

let g:airline_detect_modified=0
let g:airline_detect_spell=0
let g:airline#extensions#tabline#enabled = 1
" let g:airline_theme='dark_minimal'
" -------------------------------------------
let g:airline#extensions#eclim#enabled = 1
let g:airline#extensions#wordcount#enabled = 0
let g:airline_powerline_fonts = 1
let g:airline_theme='solarized'
let g:airline_solarized_dark_inactive_border = 1
" set t_Co=256

" get rid of rightmost triangle, small perf. penalty
" let g:airline_skip_empty_sections = 1

if !exists('g:airline_symbols')
	let g:airline_symbols = {}
endif
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''
" to look like non-powerline version:
"let g:airline_left_sep = ''
"let g:airline_right_sep = ''
"let g:airline_left_alt_sep = ''
"let g:airline_right_alt_sep = ''
"let g:airline#extensions#tabline#left_sep = ' '
"let g:airline#extensions#tabline#left_alt_sep = '|'

let g:airline#extensions#syntastic#enabled = 0
let airline#extensions#syntastic#error_symbol = 'E:'
let airline#extensions#syntastic#warning_symbol = 'W:'
" ------------------------------------------------------------------------------

" -------------------- Vim-easymotion
" The new/latest default mapping of easymotion is <Leader><Leader>, that is
" double-pressing <Space> in my case. Using old mapping of sinle <Leader>,
" even though it may break some future plugins (check when installing new
" plugins that there is no conflict between it and easymotion).
" original command:
" map <Leader> <Plug>(easymotion-prefix)

" TODO maybe redo mappings? (see above mapping leader to <nop>)
" The below will undo all easymotion mappings (dunno why)
" let g:EasyMotion_do_mapping = 0
" ------------------------------------------------------------------------------

" -------------------- Vim-exchange
" c-x marks for exchange in visual-only, default is "X" aka my black hole delete
" (manual suggests xmap, doesnt say anything about xnoremap)
" Reminder:
" (must be pressed in rather quick succession, has smth to do with timeout)
" cxc clears any selections
" cxx exchanges lines
" dot operator "." is usually what is used on the second text piece in exchange
" xnore does not work, so using xmap
xmap <C-X> <Plug>(Exchange)

" -------------------- YouCompleteMe
" doesnt work to manually trigger identifier completion
let g:ccc = 'call feedkeys("\<C-x>\<C-u>\<C-p>", "n")'
inoremap <silent><c-v> <c-r>=execute(g:ccc)<CR>
inoremap <silent><c-v> <c-r>=feedkeys("\<C-x>\<C-u>\<C-p>", "n")<CR>

" Works: Manually trigger ycm without losing identifier completion:
inoremap <silent><C-l> <C-r>=execute('let g:ycm_auto_trigger=1 \| doautocmd <nomodeline> ycmcompletemecursormove TextChangedI \| let g:ycm_auto_trigger=0')<CR>
inoremap <silent><C-l> <C-r>=execute("let g:ycm_auto_trigger=1 \| doautocmd <nomodeline> ycmcompletemecursormove TextChangedI \| let g:ycm_auto_trigger=0")<CR>
" The "\" before "|" is needed, else this will not run correctly. Single vs
" double quotes seem the same, keeping both just in case.
" The above but with a list:
inoremap <silent><C-l> <C-r>=execute(['let g:ycm_auto_trigger=1' , 'doautocmd <nomodeline> ycmcompletemecursormove TextChangedI' , 'let g:ycm_auto_trigger=0'])<CR>
se	se
" "silent" is the default either way
inoremap <silent><C-l> <C-r>=execute(['let g:ycm_auto_trigger=1' , 'doautocmd <nomodeline> ycmcompletemecursormove TextChangedI' , 'let g:ycm_auto_trigger=0'], "silent")<CR>
" "silent!" will suppress error msgs as well
inoremap <silent><C-l> <C-r>=execute(['let g:ycm_auto_trigger=1' , 'doautocmd <nomodeline> ycmcompletemecursormove TextChangedI' , 'let g:ycm_auto_trigger=0'], "silent!")<CR>

" WORKAROUND-YCM1 FOR https://github.com/Valloric/YouCompleteMe/issues/526
" When using <BS> completion results change and become fewer.
" <C-w> to begin typing again will give correct results, but maybe not worth
" retyping. This will most likely break deletion in any pair auto close plugins.
" inoremap <expr><BS> pumvisible()? "\<C-y>\<BS>" : "\<BS>"

" " Should not use <c-p>, <c-x>, <c-u>, conflicts with ycm (ycm disables it too)
" inoremap <C-p> <nop>
" inoremap <C-x> <nop>
" inoremap <C-u> <nop>

" THIS IS THE BEST WAY FOR PREVENTING COMPLETION:
" (still a hack though)
" It will not re-trigger anything, but will not hide the usual menu.
" Still, much better. Maybe should be called on vimenter (as would not be
" recognized otherwise?)
" call youcompleteme#DisableCursorMovedAutocommands()
" call youcompleteme#EnableCursorMovedAutocommands()

" also to consider preventing completion:
" (this should also halt collection of identifiers and reparsing on change)
" :let b:ycm_largefile = 1
" :unlet b:ycm_largefile

" this should kill popup on next char with au InsertCharPre:
" if pumvisible()
" 	call feedkeys( "\<C-e>", 'n' )
" endif

" UNSOLVABLE ISSUE: (???) ycm feeds the whole line to ycm, meaning that:
" // s is a string, try to fuzzy complete "s.toLowercase":
" s.tlc<c-space>       <-- error: eclim cannot resolve s to a type.
" Confusingly, it WILL work if "s.<c-space>" was pressed right before on the
" same line. Ycm will fetch the results from cache and fuzzy complete
" correctly. Need to adjust the pattern to cut whatever follows "." yet use it
" to fuzzy filter the results from eclim omni. When using auto-trigger this is
" not an issue, since as soon as "." was typed, ycm's cache was filled and
" fuzzying is correct.

" TODO figure out how to manually trigger the real completion function:
" youcompleteme#CompleteFunc(...)

" do not trigger as-I-type-completion
let g:ycm_auto_trigger = 1

" do not cache eclim's omnifunc, will break fuzziness - see above.
" let g:ycm_cache_omnifunc = 0

" complete language keywords from vim syntax file
let g:ycm_seed_identifiers_with_syntax = 1

" complete using ctags
let g:ycm_collect_identifiers_from_tags_files = 1

" let g:ycm_always_populate_location_list = 1
" auto close preview after leaving insert mode
" Lets keep it == 0 since we dont allow it in menuopt anyway
let g:ycm_autoclose_preview_window_after_insertion = 0

" stop highlighting warning/error parts of line, causes highlighing at the
" same point in all the other open buffers
let g:ycm_enable_diagnostic_highlighting = 0

" if =1 adds preview to completeopt, if not there already, 0 is default
let g:ycm_add_preview_to_completeopt = 0

let g:ycm_min_num_of_chars_for_completion = 2

" only menu (even if only one valid suggestion result), ycm auto sets it to menuone too
" set completeopt=menuone
" complete in comments too
let g:ycm_complete_in_comments = 1
" TODO make a mapping trigger preview opening on demand while completing

" TODO try out calling ycm's autocmd as callbacks:
" assuming ycm_min_num_of_char == 0 initially
" Timer:
" set ycm-auto-popup true (or maybe set min_num_chars to 0 here, see below)
" doautocmd ycm-on-insert-leave (as if we pressed esc)
" doautocmd ycm-on-insert-enter (as if we pressed insert)
" InsertPre: (with <nomodelines>???)
" pumvisible -> <c-y> to close popup (ycm already does it?)
" set ycm-auto-popup false (or maybe set min_num_chars to 100, effectively
" disabling identifier based completion)
" if needed:
" doautocmd ycm-on-insert-leave (as if we pressed esc)
" doautocmd ycm-on-insert-enter (as if we pressed insert)

" ------------- completion after 1500ms with CursorHoldI --------------------
" " Dont use swapfile, needed for setting low updatetime values.
" " Manual says all text will be in memory, dont use this for big files, likely
" " no problems on high ram systems.
" set noswapfile
" " Set updatetime - CursorHold and CursorHoldI trigger after this time
" " autocommands (also used to write swap, default is 4000 ms)
" " To be used to set my artificial delay of YouCompleteMe.
" " UPDATE: better use timers, see below.
" set updatetime=500

" " this will work as a test without ycm
" " but skips every second letter popup after the initial popup
" set updatetime=500
" autocmd! CursorHoldI * call feedkeys("\<c-n>\<c-p>") | echom "cncpfeedkeysDDD"
" " TODO maybe it is related to popup being visible?(pumvisible) or because my autocmd are
" executed first. To make them execute last, I should make them into a plugin
" and load it first. Test the following:
" inore <c-y> <nop>
" autocmd! CursorHoldI * call feedkeys("\<c-y>\<c-n>\<c-p>") | echom "cncpfeedkeysDDD"

" this works and will trigger once per completion initiation, that is
" continuing to type after menu pop will not trigger additional <c-spaces>
" until after next <space> is inserted.
" autocmd! CursorHoldI * call feedkeys ("\<C-Space>") | echom "semanticfeedkeysDDD"
" warning: weird behaior of feedkeys:
" autocmd! CursorHoldI * call feedkeys ("a") | echom "aaaaa"
" as it will trigger EVERY updatetime, although <c-space> will trigger once
" per menu popup.

" The following will autotrigger the semantic completion after 'updatetime':
" This is hacky though as it relies on the internal function that gets mapped
" to <C-Space>.
" autocmd CursorHoldI * :call <SNR>70_InvokeSemanticCompletion() | echom "semanticDDD"
" InvokeCompletion will trigger only every second letter, but provides
" identifier completion, feedkeys will re-trigger after updatetime (likely a
" bug in vim)
" autocmd CursorHoldI * :call <SNR>70_InvokeCompletion() | echom "nonsemanticDDD"
" autocmd! CursorHoldI * :call feedkeys ("\<C-Space>") | echom "semanticfeedkeysDDD"
" TODO: try autocmd to set g:ycm_auto_trigger to 1 and 0 and see if it can
" pick it up in the middle of completion - does not work
" autocmd! CursorHoldI * :let g:ycm_auto_trigger=1 | call <SNR>70_InvokeSemanticCompletion() | call <SNR>70_OnCompleteDone()
" autocmd InsertCharPre * :let g:ycm_auto_trigger=0
" autocmd CompleteDone * :let g:ycm_auto_trigger=0
" autocmd TextChangedI * :let g:ycm_auto_trigger=0
" "-----------------------------------------------------------------------------

" -------------- completion after 1500ms with timers ---------------------------
" " for debugging / timers demo:
" function! MyComplPresserFunc(timer)
" 	" only the last will trigger
" 	if exists('g:myLastComplTimerIdDDD') && g:myLastComplTimerIdDDD ==# a:timer
" 		unlet g:myLastComplTimerIdDDD
" 		" call feedkeys("\<c-n>\<c-p>")
" 		echom a:timer . " pressed"
" 	else
" 		echom "concurrent " . a:timer . " not pressed"
" 	endif
" endfunction
" autocmd TextChangedI * echom "TextChangedI" | let g:myLastComplTimerIdDDD = timer_start(1500, 'MyComplPresserFunc')

" " now the real running code:
" function! MyComplPresserFunc(timer)
" 	" only the last will trigger, as each new TextChangedI autocmd overwrites
" 	" g:myLastComplTimerIdDDD, so that when MyComplPresserFunc() callbacks are
" 	" executed they do nothing, except the last. That is, every subsequent
" 	" TextChangedI autocmd "invalidates" the previous one, which in turn
" 	" "invalidated" the one before it etc...
" 	if exists('g:myLastComplTimerIdDDD') && g:myLastComplTimerIdDDD ==# a:timer
" 		unlet g:myLastComplTimerIdDDD
" 		call feedkeys("\<c-n>\<c-p>")
" 		" better not have whatever in feedkeys mapped in norm (see below)
" 	endif
" endfunction
" augroup MyCompletionTriggerDDD
" 	autocmd!
" 	" autocmd TextChangedI * let g:myLastComplTimerIdDDD = timer_start(1500, 'MyComplPresserFunc')
" 	" autocmd InsertEnter * let g:myLastComplTimerIdDDD = timer_start(1500, 'MyComplPresserFunc')
" 	" autocmd InsertLeave * if exists('g:myLastComplTimerIdDDD')
" 	" 			\ | unlet g:myLastComplTimerIdDDD | endif
" 	" autocmd InsertLeave * if exists('g:myLastComplTimerIdDDD')
" 	" 			\ | call timer_stop(g:myLastComplTimerIdDDD) | unlet g:myLastComplTimerIdDDD | endif
" 	" P.S. Not sure what happens if there is a race condition when <esc>
" 	" is pressed right at the moment of 1500ms and both the autocmd and
" 	" the MyComplPresserFunc callback try to unlet g:myLastComplTimerIdDDD at
" 	" the same time. TODO investigate whether there are locks. How safe is
" 	" this? Also, pipe (:h bar) will stop subsequent execution if one of
" 	" commands errors out. This can leave us with an unclosed 'if'? Maybe
" 	" 'try-catch' is better.
" 	" TODO maybe better to set ID out of range instead of unlet? What is
" 	" the range of IDs generated? It is integer, but is it overflown?
" 	" Also, unlet! does not produce error and does not prevent | execution!
" augroup END

" until I clarify the above this is the working variant
let g:myLastComplTimerIdDDD = -1
function! MyComplPresserFunc(timer)
	" only the last will trigger, as each new TextChangedI autocmd overwrites
	" g:myLastComplTimerIdDDD, so that when MyComplPresserFunc() callbacks are
	" executed they do nothing, except the last. That is, every subsequent
	" TextChangedI autocmd "invalidates" the previous one, which in turn
	" "invalidated" the one before it etc...
	" From tests IDs returned by timer_start are auto-incremening
	" integers, so maybe they are overflown when reaching 32bit max
	" 32bit max int == 2,147,483,647
	if g:myLastComplTimerIdDDD ==# a:timer
		let g:myLastComplTimerIdDDD = -1
		call feedkeys("\<c-n>\<c-p>")
		" better not have whatever in feedkeys mapped in norm (see below)
	endif
endfunction
augroup MyCompletionTriggerDDD
	autocmd!
	" " TextChangedI does not trigger when popup is open (it does not autoclose)
	" autocmd TextChangedI * let g:myLastComplTimerIdDDD = timer_start(1500, 'MyComplPresserFunc')
	" autocmd InsertLeave * let g:myLastComplTimerIdDDD = -1
	" " autocmd InsertEnter * let g:myLastComplTimerIdDDD = timer_start(1500, 'MyComplPresserFunc')
augroup END

" " ------------------- Javacomplete2
" autocmd FileType java setlocal omnifunc=javacomplete#Complete
" " " unmap all default mappings
" " nunmap <leader>jI
" " nunmap <leader>jR
" " nunmap <leader>ji
" " nunmap <leader>jii

" " iunmap <C-j>I
" " iunmap <C-j>R
" " iunmap <C-j>i
" " iunmap <C-j>ii

" " nunmap <leader>jM

" " iunmap <C-j>jM

" " nunmap <leader>jA
" " nunmap <leader>js
" " nunmap <leader>jg
" " nunmap <leader>ja
" " nunmap <leader>jts
" " nunmap <leader>jeq
" " nunmap <leader>jc
" " nunmap <leader>jcc

" " iunmap <C-j>s
" " iunmap <C-j>g
" " iunmap <C-j>a

" " vunmap <leader>js
" " vunmap <leader>jg
" " vunmap <leader>ja

" " nunmap <silent> <buffer> <leader>jn
" " nunmap <silent> <buffer> <leader>jN

" " -------------- vim-shell --------------------------------------------
" " dont be always on top, so that alt-tabbing works
let g:shell_fullscreen_always_on_top = 0
" " dont use default mappings
let g:shell_mappings_enabled = 0
" " prevent airline's tab line from being hidden
let g:shell_fullscreen_items=''
" nnoremap <F11> :Fullscreen<CR>

" -------------- regex ------------------------------------------------
" :h usr_27.txt
" :h pattern

" ------------- neocomplete
" Autodetected value,to manually disable using it. To check if neovim has
" recognized vimproc: echo neocomplete#has_vimproc()
" let g:neocomplete#use_vimproc

" After dot and text completion: "b.tst|" -> "b.toString()|". Has delay/flashes.
" inoremap <c-l> <c-left><C-r>=neocomplete#mappings#start_manual_complete()<CR><esc>ea<C-r>=neocomplete#mappings#start_manual_complete()<CR>
" imap <silent> <c-l> <c-left><c-r>=execute('let g:neocomplete#disable_auto_complete = 0')<cr><c-space><esc>ea<c-space><c-r>=execute('let g:neocomplete#disable_auto_complete = 1')<cr>
imap <silent> <c-m> <c-left><c-r>=execute('let g:neocomplete#disable_auto_complete = 0')<cr><C-r>=neocomplete#mappings#start_manual_complete()<CR><esc>ea<C-r>=neocomplete#mappings#start_manual_complete()<CR><c-r>=execute('let g:neocomplete#disable_auto_complete = 1')<cr>
" TODO: try to achieve the same with saving cursor position with getpos, doing
" <c-l>, then restoring cursor position with setpos, its possible that
" flipping disable_auto_complete switch will not be needed (like in ycm)


" let g:neocomplete#sources#omni#input_patterns.java = '\%(\h\w*\|)\)\.\w*'
" let g:neocomplete#sources#omni#input_patterns.java = '\k\.\k*'
" let g:neocomplete#sources#omni#input_patterns.java = '\h\w*\.\w*'
" let g:neocomplete#sources#omni#input_patterns.java = '\(\S.*\.\)\+[^;]*'

" ----------------------------------
" In foxit to get j and k to go to next/prev page -> right click ribbon ->
" "Customize ribbon" -> "Keyboard"

" -------------------------------------------
" prev tpope/vim-commentary commit
Plug 'tpope/vim-commentary', {'commit': 'be79030b3e8c0ee3c5f45b4333919e4830531e80'}
" ^^ Changing the above because it is too simple and will not use correct
" comment-delimiters in code-embedded-in-other-code (like css-in-html, js-in-html, jsx too?)
