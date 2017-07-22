" location of vimrc on windows c:\users\username\_vimrc
set nocompatible               " Be iMproved

" May help with scrolling, may worsen flicker of completion popup menu
" Also may cause glitch with ycm when typing very fast, where ycm will display
" identifier (words from file) suggestions, but as if 2 last letters were not
" typed. Example: set lazyredraw and type very fast "w e r e r" (without
" spaces), then ^w until " incorrect suggestion appears.
" Setting power options to "Power saver mode" in Windows helps expose the bug.
" Also check:http://eduncan911.com/software/fix-slow-scrolling-in-vim-and-neovim.html
" set lazyredraw
set synmaxcol=128
" syntax sync minlines=256

" Version-controlled installation of vim-plug, that will be self-updatable
" manually later. On windows console:
" cd %USERPROFILE%
" (from git bash this becomes cd $homepath)
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
" TODO make a check on startup to make sure that on windows the vimfiles dir is
" either empty or does not exist? (display an error and exit)
if !has('nvim') && (has('win32') || has('win64'))
	set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
	let g:plughomeddd='~/.vim/plugged'
	" always start in home dir on windows
	cd ~
else
	let g:plughomeddd='~/.vim/plugged'
endif

" ================== Plugin manager ===========================================
" TODO migrate to pathogen and version control using git ("git submodule add" etc)
" iff there is a way in pathogen to ensure the plugin loading order (maybe
" prepend plugin dirs with numbers like 01_vim_airline/ etc and then clone
" into them and check the order in runtimepath).
" call plug#begin('~/vimfiles/plugged')
" call plug#begin('~/.vim/plugged')
call plug#begin(g:plughomeddd)

" --------------- Themes + visual
"Plug 'dimxdim/jellybat'

" solarized, supposedly more consistent than orig
" prev romainl/flattened commit
Plug 'romainl/flattened', {'commit': '048ad9e570a6b0cd671618ccb0138c171e0b9c52'}

" original solarized
" prev altercation/vim-colors-solarized commit
Plug 'altercation/vim-colors-solarized', {'commit': '528a59f26d12278698bb946f8fb82a63711eec21'}

" another solarized, between the above 2
" prev lifepillar/vim-solarized8 commit
Plug 'lifepillar/vim-solarized8', {'commit': 'b64bca5f6ce418589986a03e37df53b3d0625575'}

" Plug 'flazz/vim-colorschemes'
" Plug 'NLKNguyen/papercolor-theme'

" --------------- Plugins
" prev vim-airline/vim-airline commit a914cfb75438c36eefd2d7ee73da5196b0b0c2da
" Plug 'vim-airline/vim-airline', {'commit': '72ca1c344fc48f8a5dec7e8c4b75da0436176338'}

" prev vim-airline/vim-airline-themes commit
Plug 'vim-airline/vim-airline-themes', {'commit': '7865fd8ba435edd01ff7b59de06a9be73e01950d'}

Plug 'itchyny/lightline.vim'
Plug 'mgee/lightline-bufferline'
" " Alternative to bufferline
" " Plug 'taohex/lightline-buffer'

" Plug 'powerline/powerline'


" prev easymotion/vim-easymotion commit d55e7bf515eab93e0b49f6f762bf5b0bf808264d
Plug 'easymotion/vim-easymotion', {'commit': 'e4d71c7ba45baf860fdaaf8c06cd9faebdccbd50'}

" prev jiangmiao/auto-pairs commit
" problematic with neocomplete, it maps <space> by default, can be fixed by
" setting let g:AutoPairsMapSpace=0.
" Alternative: delimitmate, suggested by ycm, also neopairs by shougo
Plug 'jiangmiao/auto-pairs', {'commit': '6afc850e2429e6832a1b093e32a31e0b5eff477d'}

" prev tommcdo/vim-exchange commit
Plug 'tommcdo/vim-exchange', {'commit': '05d82b87711c6c8b9b7389bfb91c24bc4f62aa87'}

" prev tpope/vim-surround commit
Plug 'tpope/vim-surround', {'commit': 'e49d6c2459e0f5569ff2d533b4df995dd7f98313'}

" prev tpope/vim-commentary commit
Plug 'tpope/vim-commentary', {'commit': 'be79030b3e8c0ee3c5f45b4333919e4830531e80'}

" make the above 2 repeatable
Plug 'tpope/vim-repeat', {'commit': '070ee903245999b2b79f7386631ffd29ce9b8e9f'}

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
Plug 'Shougo/vimproc.vim', {'commit': '57cad7d28552a9098bf46c83111d9751b3834ef5'}

" YouCompleteMe should be updated on its own (so that it does not timeout) using:
" :PlugUpdate YouCompleteMe
" Neovim: check with :CheckHealth if python3 provider is correct.
" also check :messages to see whether ycm complains
" ycm -> was installed by .\install.py --clang-completer --tern-completer
" Plug 'Valloric/YouCompleteMe', {'commit': 'b564b5d8e3858225723f91f41e1b0a4b6603a1b8'}

" Fullscreen gvim on windows
" download dll's from https://github.com/derekmcloughlin/gvimfullscreen_win32
" and put them where gvim.exe is. Mapping is at the end.
Plug 'derekmcloughlin/gvimfullscreen_win32', {'commit': '6abfbd13319f5b48e9630452cc7a7556bdef79bb'}
" " Also fullscreen functionality (vim-shell + vim-misc, should work on unix too):
" vim-misc is required by vim-shell
" Plug 'xolox/vim-misc', {'commit': '3e6b8fb6f03f13434543ce1f5d24f6a5d3f34f0b'}
" vim-shell, to be used for :Fullscreen command etc
" Plug 'xolox/vim-shell', {'commit': 'c19945c6cb08db8d17b4815239e2e7e0051fb33c'}

" tern-js for javascript (unneeded, as ycm already includes it?)
" Plug 'ternjs/tern_for_vim', {'commit': 'ae42c69ada7243fe4801fce3b916bbc2f40ac4ac'}

" javacomplete2
" Plug 'artur-shaik/vim-javacomplete2', {'commit': 'ae351ecf333e77873fa4682b4d4b05f077047bc4'}

" Needs lua53.dll from http://lua-users.org/wiki/LuaBinaries (64bit like my vim) in the same dir as gvim.exe
" alternative source for lua binaries, mentioned on github vim distribution:
" http://luabinaries.sourceforge.net/download.html
" (also according to shougo/denite python can also be added this way from
" official site -> choose python embeddable and copy all zip contents to vim's
" install dir)
Plug 'Shougo/neocomplete', {'commit': '186881fc40d9b774766a81189af17826d27406c2'}

" TODO check out Ultisnips later, supposedly works well with ycm
" TODO check out nerdtree,
" TODO vim-javascript and flow for javascript static checking, also ternjs.
" TODO w0rp/ale, async linting, like syntastic?
" TODO check out ctrlp and also FelikZ/ctrlp-py-matcher for faster ctrlp
" also it is supposedly better on windows with ag. Ripgrep must be even
" faster.
" TODO check out IndentLine plugin to show | in projects using spaces.
" TODO check out EMMET plugin for efficient html production.
call plug#end()

" for powerline
" set runtimepath+=$HOME/.vim/plugged/powerline/powerline/bindings/vim

" eclim -> was installed by the installer with checked android support
" TODO investigate eclim integration with airline bug:
" when error occurs it is not shown in airline upon save, but upon next
" modification after save. Also goes away (after error is fixed) not upon
" saving but after saving and modifying. Possibly unrelated, but dont forget
" to set encoding to utf-8 in eclipse too.
" TODO check out CompleteTags for xml, html, md
" TODO check out michaeljsmith/vim-indent-object for selecting based on indentation
" TODO FYI alternative for airline mgee/lightline-bufferline.
" TODO check out fast fold plugin, folding may slow down autocompletion.
" TODO check out dispatch as async runner
" TODO check out tagbar for code's outline based off tags (classes, methods etc)
" TODO tag generation and updating: Gutentags


" Never upgrade vim-plug itself automatically:
delc PlugUpgrade
" =============================================================================

" ================== My settings =============================================
set backupcopy=yes " make windows change the linked file when editing symlinks
" no more netrw
let g:loaded_netrwPlugin = 1
" ------------------ GUI fonts
" as of Jul 2017 nvim always returns 0 for has("gui_running")
if has("gui_running")
	if has("gui_gtk2") " TODO add gtk3 too
		set guifont=Source\ Code\ Pro\ Medium\ 10
		" no extra spacing - not checked on gtk vim linux
		set linespace=0
	elseif has("x11")
	" Also for GTK 1
		set guifont=*-lucidatypewriter-medium-r-normal-*-*-180-*-*-m-*-*
	elseif has("gui_win32")
		set guifont=Source_Code_Pro_Medium:h10:cANSI:qDRAFT
		" no extra spacing, linespace was 1 by default, increase if
		" underlines cover other lines
		set linespace=0
		" set renderoptions=type:directx " see below, do not set for now
	endif
endif

" directx renderer will also render font shapes differently.
" to test, :h airline, start changing rop, check "i" shapes, some may render the dot too close, some "l" may be rendered as |.
" also, may affect performance (slower scrolling),
" try adding more than directx if rendering is ugly - in my w10_x64 made no difference
" set rop=type:directx,gamma:1.0,contrast:0.5,level:1,geom:1,renmode:4,taamode:1 -recom. by airline
" set renderoptions=type:directx,level:0.75,gamma:1.25,contrast:0.25,geom:1,renmode:5,taamode:1

"" System general settings
set shortmess+=I                                    " disable start message
set mouse=a                                         "enable mouse
set encoding=utf-8                                  "set encoding for text
set ttyfast                                         "assume fast terminal connection, fast redraws
set hidden                                          "allow buffer switching without saving
set fileformats+=mac                                "add mac to auto-detection of file format line endings
set nrformats-=octal                                "always assume decimal/hex numbers
set noshortname                                     "no dos-style short names for files

"" Visual general settings
set showcmd             " show (partial) command in bottom-right
set number              " show line numbers
syntax on           " syntax enable syntax processing, *syntax on* overrides with defaults!
set showmatch           " highlight matching [{()}]
set scrolloff=200		" no. of lines shown above/below cursor, large no. will always have cursor in middle
set noerrorbells visualbell t_vb= " no error bells at all
autocmd GUIEnter * set visualbell t_vb= " needed as gvim will reset t_vb

"" Tabs and spaces
"set tabstop=4       " number of visual spaces per TAB
"set softtabstop=4   " number of spaces in tab when editing
"set shiftwidth=4    " for indentation command in normal mode
"set expandtab       " tabs are spaces
"set shiftround    " use multiple of shiftwidth when indenting with '<' and '>'
set backspace=indent,eol,start      "allow backspacing everything in insert mode
set list                 "highlight whitespace
"set listchars=tab:│\ ,trail:•,extends:❯,precedes:❮,nbsp:■	" does not display on windows without directx render
set listchars=tab:│\ ,trail:•,extends:»,precedes:«,nbsp:■
"set shiftround			" Round indent to multiple of 'shiftwidth'. +Applies to > and <
"set smarttab		" insert blanks according to shiftwidth (else tabstop or softtabstop)
set wrap            " wrap text on eol (default)
" let &showbreak='↪ '	" does not display on windows without directx render
let &showbreak='▶ '	" Char to signify line break
set autoindent		" The simplest automatic indent

" force redraw on focus gain, fixes some visual bugs under gvim + windows
" will cause commands that spawn windows command prompt (like :PingEclim
" to be shown without the returned text, but with "press any key"), to see
" them use :messages (":mes")
if has('gui_running')
	augroup RedrawOnFocusDDD
		autocmd!
		autocmd FocusGained * :redraw!
	augroup END
endif

" Clipboard
if exists('$TMUX')
	set clipboard=
else
	if has('unnamedplus')
		set clipboard=unnamedplus                             "sync with "CLIPBOARD" OS clipboard, uses "+ register
	else
		set clipboard=unnamed                             "sync with "PRIMARY" OS clipboard, uses "* register
	endif
endif

" Searching
set incsearch           " search as characters are entered
set hlsearch            " highlight matches
set ignorecase          "ignore case for searching

" Wildmenu
set wildmenu            " visual autocomplete for command menu
set wildmode=list:longest,full		" complete longest common, then cycle with tab, back cycle shift-tab
set wildignorecase		" ignore case in wildmenu search

"" Keyboard and cursor
set timeout ttimeout         " enable separate mapping and keycode timeouts
set timeoutlen=400                                  "mapping timeout ms (default 1000)
set ttimeoutlen=50                                  "keycode timeout ms (default -1, unset when having ssh with latency)

" Add tags from tag folder (libraries)
" remove searching tags in current file's directory
" tags should be read only from ~/tags/*.tags and from current working dir
" (not from current file's dir if its different from working dir)
set tags-=./tags
set tags-=./TAGS
set tags+=~/tags/cpp_std_gcc.tags
set tags+=~/tags/qt5.tags

"" Tags
"" if has('path_extra') " from sensible.vim
""  setglobal tags-=./tags tags^=./tags;
"" endif
"" set tags=tags;/			" from bling's vimrc
"set showfulltag 		" shows tag and search pattern as matches

" always split below, when opening help/quickfix/etc
set splitbelow

" GUI
if has('gui_running')
	set guicursor=a:blinkon0 " dont blink, the rest are defaults ddd new
	"set guicursor=n-v-c:blinkon0-block-Cursor/lCursor,ve:ver35-Cursor,o:hor50-Cursor,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor,sm:block-Cursor-blinkwait175-blinkoff150-blinkon175 "dont blink
	"let &guicursor = substitute(&guicursor, 'n-v-c:', '&blinkon0-', '')
	"set guicursor=
	" set lines=999 columns=9999  " open maximized (not always works)
	set guioptions-=t                                 "no tear off menu items
	set guioptions+=c                                 "no gui dialogs
	set guioptions-=T                                 "no toolbar icons
	set guioptions-=r                                   " no right scrollbar
	set guioptions-=l           " no left scrollbar
	set guioptions-=L           " no left scrollbar when vert. split
	set guioptions-=m           " no menu
	set guioptions-=e           " no ugly GUI-style tabline
endif

" Setting formatoptions to define behavior when pressing enter on commented line to
" continue comments etc
" "set formatoptions" can be overriden by plugins
" https://superuser.com/questions/401090/how-to-prevent-certain-vim-formatoptions-from-being-enabled-by-ftplugins
" Using augroup to be able to :source % multiple times without adding new
" autocommands each time. -=c will remove comment auto-line-break (:h formatoptions)
augroup myFormatOptsDDD
	autocmd!
	autocmd FileType * setlocal formatoptions-=t formatoptions-=o
augroup END

" Key remaps
" Swap : and ; to make colon commands easier to type
" The vice versa remapping *may* break plugins - to be confirmed
nnoremap  ;  :
"nnoremap  :  ;
xnoremap  ;  :
"xnoremap  :  ;
" make comma the new ;
nnoremap , ;
xnoremap , ;

" Space is the new leader
" another option is "map <Space> <Leader>" but will not trigger double leader
" aka <Leader><Leader> mappings
" let mapleader = "\<Space>" if let mapleader = " " doesnt work
" also if remapped leader is continuously pressed, next leader presses will
" not be triggered until modes are changed (easymotion probably is culprit)
nnoremap <Space> <Nop>
xnoremap <Space> <Nop>
"let mapleader = " "
let mapleader = "\<Space>"

" disable <c-c> in insert, normally it exits to normal without triggering
" InsertLeave.
inoremap <c-c> <nop>

" the below 2 lines dont work somehow - spit message on startup TODO
"nnoremap \ ;   <--- problematic
"nnoremap | ,

" for navigation of wrapped lines --> investigate side effects
nnoremap j gj
nnoremap k gk

" map } and { to :bnext and :bprev
nnoremap <silent> } :bnext<CR>
nnoremap <silent> { :bprev<CR>

" jump paragraph with ( , )
nnoremap ( {
nnoremap ) }

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

" we can also indent the pasted text - a bit twitchy/flashing due to reselection
"xnoremap p "_dPV`]=
" that's why we can use =`]
" (`] marker-motion == jump to end to previously changed/yanked text)
"
" xnoremap p "_dP=`]
" nnoremap p p=`]

" x is the new black hole
" x in normal or visual will not overwrite the paste buffer
nnoremap x "_x
xnoremap x "_x

" TODO make dd delete to black hole if line is empty/whitespaces

" X deletes to black hole till end of line
nnoremap X "_D

" Y yanks till end of line, instead of whole line
nnoremap Y y$

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

" GUI doesnt need workaround, so lets not add the delay of <esc><esc>.
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

"====[ Swap V and CTRL-v. Regular visual is now Shift-v. ]======
"====[ Block mode is more useful that Visual mode ]======
nnoremap    v   <C-V>
xnoremap    v   <C-V>
nnoremap <C-V>     V
xnoremap <C-V>     V
nnoremap    V   v
xnoremap    V   v

" move to beginning/end of line (also consider B and E as alternative)
" <C-H> by default in terminal is produced by backspace, using <C-J>
noremap <C-J> ^
noremap <C-K> $
" <C-K> appends to end of line, useful to escape auto-closing parens
inoremap <silent><C-J> <ESC><ESC>I
inoremap <silent><C-K> <ESC><ESC>A
" command mode move to beginning/end
cnoremap <C-A> <Home>
cnoremap <C-L> <End>

" ----------------------------------------------------------------
" paste from main buffer in command mode, filterling out tabs and newlines
" does not modify the main register, as it uses r register
" this is useful for copy-pasting lines into command mode lines from vimrc.
" This will not work on multi-line selections to be pasted into command, but
" you should not do such things anyway.
" double c-r at end to insert literally (whe yanked text contains "^h" it will
" not result in <BS> performed)
" cnoremap <C-R> call <SID>FilterNLTabYankToRegrR()<CR>:<C-R><C-R>r
" <C-R>= prompts for an expression, BS will delete the 0 from the expression.
cnoremap <C-R> <C-R>=<SID>FilterNLTabYankToRegZ()<CR><BS><C-R><C-R>z
" filters tabs and new lines from clipboard: @+ into reg r: @r
" tabs are replace by space just in case.
function! s:FilterNLTabYankToRegZ()
	let @z=substitute(@+, '\n', '', 'g')
	let @z=substitute(@z, '\t', ' ', 'g')
endfunction

" source selected lines into vim command (useful when testing scripts) using
" register z. Does not support line continuations "\"
" TODO: investigate and make into function to not pollute register z.
" xnoremap <Leader>r "zy:@z<CR>

":[range]MyExecuteLineRangeDDD    Execute text lines as ex commands.
"           Handles |line-continuation|.
command! -bar -range MyExecuteLineRangeDDD silent <line1>,<line2>yank z | let @z = substitute(@z, '\n\s*\\', '', 'g') | @z
xnoremap <Leader>r :MyExecuteLineRangeDDD<CR>

" use <C-T> to paste from specific register (the original <C-R> is now <C-T>)
cnoremap <C-T> <C-R>

" ----------------------------------------------------------------
" c-d exits(if last window, else closes window), aka always close window.
" Now it will not quit when having open an single buffer and a help window!
" TODO: shorten this to an expression mapping
" nnoremap <expr> <C-D> winnr() ==# winnr('$') ? execute 'quit'  : execute 'wincmd c')
nnoremap <C-D> :call MyCloseFuncDDD()<CR>
function! MyCloseFuncDDD()
	if winnr() ==# winnr('$')
		quit
	else
		wincmd c
	endif
endfunction
" c-s writes(if buffer was modified), c-c deletes buffer
nnoremap <silent><C-S> <ESC><ESC>:update<CR><ESC>
inoremap <silent><C-S> <ESC><ESC>:update<CR><ESC>
" <c-c> interrupts terminal vim when busy (useful to break from endless loop)
" even if remapped. In GUI when remapped -> use CTRL-Break
nnoremap <silent><C-C> :bdelete<CR>
" ----------------------------------------------------------------

" <leader>s performs substitution
" nnoremap <Leader>s :%s//<left>
nnoremap <Leader>s :%s/

" Reselect pasted text linewise, ( `[ is jump to beginning of changed/yanked )
nnoremap <Leader>v `[V`]

" Uppercase current word in norm/insert
nnoremap <C-\> gUiw
inoremap <C-\> <ESC>gUiwea

" Jump a word forward in insert mode
inoremap <C-e> <ESC>ea
" Jump a word back in insert mode
inoremap <C-b> <ESC>bi

"====[ '*' in visual to search on selection - the correct way ]=============
" <c-u> is needed to remove '<'> of visual
" edit: since * is just too far, <c-f> will become new * for visual and norm.
" xnoremap * :<C-u>call <SID>VSetSearch()<CR>/<C-R>=@/<CR><CR>
nnoremap * <nop>
xnoremap * <nop>
" <c-f> is the new * (F is for Find)
nnoremap <C-f> *
xnoremap <C-f> :<C-u>call <SID>VSetSearch()<CR>/<C-R>=@/<CR><CR>
" backward search on #
xnoremap # :<C-u>call <SID>VSetSearch()<CR>?<C-R>=@/<CR><CR>
" The function itself
function! s:VSetSearch()
	let temp = @s
	norm! gv"sy
	let @/ = '\V' . substitute(escape(@s, '/\'), '\n', '\\n', 'g')
	let @s = temp
endfunction

" In visual search for current selection to make it substitution target
" xmap <Leader>s *:<C-u>%s//
xnoremap <Leader>s :<C-u>call <SID>VSetSearch()<CR>:<C-u>set hlsearch<CR>:<C-u>%s//
" ============================================================================

" Cool terminal shape when in xterm
if &term =~ '^xterm'
	" solid underscore
	let &t_SI .= "\<Esc>[6 q"
	" solid block
	let &t_EI .= "\<Esc>[2 q"
	" 1 or 0 -> blinking block
	" 2 solid block
	" 3 -> blinking underscore
	" 4 -> solid underscore
	" Recent versions of xterm (282 or above) also support
	" 5 -> blinking vertical bar
	" 6 -> solid vertical bar

	" 24bit color for mintty -> to be checked on xterm, hopefully perform.
	" is not affected and we can stop sourcing custom colors into xterm.
	if exists('$OS') && $OS ==# 'Windows_NT'
		set termguicolors
	endif
endif

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

" nvim with GUI
" if has('nvim')
" " 	autocmd VimEnter * GuiFont! Source Code Pro Medium:h10
" " could not make it work yet. :messages says GuiFont not an editor command
" " TODO: find a way to check whether neovim is running in gui.
" GuiFont! Source Code Pro Medium:h10
" endif

" ---------------------- COLORS
set background=dark " for original solarized theme
colorscheme flattened_dark
let g:solarized_underline=1

" "" Special highlight of 81st char in long line, needs to be after colorscheme
" and after special term sequences or else it might be shown not show
" highlight MyColorColumn guifg=#d8d8d8 guibg=#ab4642 guisp=NONE gui=NONE ctermfg=7 ctermbg=1 cterm=NONE
" call matchadd('MyColorColumn', '\%81v', 100)

" after 80 columns the following columns background will be lighter (range max 256)
let &colorcolumn=join(range(81,336),",")
" to change the color of the above (better be done with augroup autocmd like
" below)
" highlight ColorColumn ctermbg=235 guibg=#2c2d27

" ------------------------------------------------------------------------------
" make completion dropdown same style as comments but underlined + not italic
" TODO make this copy values: bg->from Norm, fg->from Comment instead of hardcoded values
" To actually do the above may require parsing etc. For now lets set up
" hardcoded values depending on theme to being switched to (solarized light)
" http://vim.wikia.com/wiki/Override_Colors_in_a_Color_Scheme
" https://vi.stackexchange.com/questions/9675/use-variables-in-colorscheme
" https://vi.stackexchange.com/questions/9644/how-to-use-a-variable-in-the-expression-of-a-normal-command
" https://superuser.com/questions/466662/vim-how-to-auto-sync-custom-syntax-highlight-rules-when-colorscheme-changes
" https://stackoverflow.com/questions/12449248/vim-autocmd-for-removing-colorscheme-background-fail-to-run
" https://github.com/mhinz/vim-janah/issues/2
" when changing multiple stuff use pipes like this:
" autocmd ColorScheme * highlight Normal ctermbg=NONE guifg=lightgrey guibg=black | highlight MatchParen cterm=bold ctermfg=red ctermbg=NONE gui=bold guifg=red guibg=NONE

" my default pmenu colors for solarized_dark
highlight Pmenu term=bold cterm=underline,bold ctermfg=10 ctermbg=8
		\ gui=underline,bold guifg=#586e75 guibg=#002b36

highlight EasyMotionTarget ctermfg=12 guifg=#ff0000 gui=NONE cterm=NONE
highlight EasyMotionTarget2First ctermfg=14 guifg=#ffb400 gui=NONE cterm=NONE
highlight EasyMotionTarget2Second ctermfg=14 guifg=#b98300 gui=NONE cterm=NONE

" " remove italics from comments
" highlight Comment gui=NONE cterm=NONE

" when colorscheme is changed to solarized family dark
augroup ColorschemeChangeDDD
	autocmd!
	autocmd ColorScheme flattened_dark,solarized8_dark,solarized8_dark_flat
		\ highlight Pmenu term=bold cterm=underline,bold
		\ ctermfg=10 ctermbg=8 gui=underline,bold guifg=#586e75
		\ guibg=#002b36
		\ | highlight EasyMotionTargetDefault gui=NONE cterm=NONE
		\ | highlight EasyMotionTarget2FirstDefault gui=NONE cterm=NONE
		\ | highlight EasyMotionTarget2SecondDefault gui=NONE cterm=NONE
		\ | AirlineRefresh
	autocmd ColorScheme flattened_light,solarized8_light,solarized8_light_flat
		\ highlight Pmenu term=bold cterm=underline,bold
		\ ctermfg=14 ctermbg=15 gui=underline,bold guifg=#93a1a1
		\ guibg=#fdf6e3
		\ | highlight EasyMotionTargetDefault gui=NONE cterm=NONE
		\ | highlight EasyMotionTarget2FirstDefault gui=NONE cterm=NONE
		\ | highlight EasyMotionTarget2SecondDefault gui=NONE cterm=NONE
		\ | AirlineRefresh
augroup END

" " when colorscheme is changed to solarized family light
" augroup ColorsChangeToSolLightDDD
" 	autocmd!
" 	autocmd ColorScheme flattened_light,solarized8_light,solarized8_light_flat
" 		\ highlight Pmenu term=bold cterm=underline,bold
" 		\ ctermfg=14 ctermbg=15 gui=underline,bold guifg=#93a1a1
" 		\ guibg=#fdf6e3
" 		\ | AirlineRefresh
" augroup END

" ------------------------------------------------------------------------------
" TODO: check this, executes macro over lines
" xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<CR>

" function! ExecuteMacroOverVisualRange()
"   echo "@".getcmdline()
"   execute ":'<,'>normal @".nr2char(getchar())
" endfunction

" ------------ For any statusline plugin ----------------
set laststatus=2    " Always show status bar

" always show tabline (Note: there used to be a bug in powerline that setting
" tabline to 2 would cause vim to update the tabline for every keystroke)
set showtabline=2

" ================== Plugin settings ==========================================
" ------------------ Lightline
" See below - to be used together with other plugins for tabline /w buffers

" ------- taohex/lightline-buffer
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
" --------- mgee/lightline-bufferline
let g:lightline = {
			\ 'colorscheme': 'solarized',
			\ }
let g:lightline.tabline          = {'left': [['buffers']], 'right': [['close']]}
let g:lightline.component_expand = {'buffers': 'lightline#bufferline#buffers'}
let g:lightline.component_type   = {'buffers': 'tabsel'}
let g:lightline#bufferline#unnamed = "[No name]"
" ------------------ Airline
" TODO: set the lightest available options, else remove it.
" makes cursor lag + text flash on new appending/inserting first char - only
" when buffer was unmodified (that is, without [+]).
" do not detect modified, should not produce the above lag on first insert
" TODO: build custom statusline and tabline so that performance is good.
" The performance is currently so bad, that even entering insert causes cursor
" flicker. It's likely not a good idea to use expressions, as they will be
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

" TODO: until full customization, switch to powerline/powerline

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

" -------------------- Vim-easymotion
" The new default mapping of easymotion is <Leader><Leader>, that is
" double-pressing <Space> in my case. Using old mapping of sinle <Leader>,
" even though it may break some future plugins (check when installing new
" plugins that there is no conflict between it and easymotion).
" original command:
" map <Leader> <Plug>(easymotion-prefix)

" TODO maybe redo mappings? (see above mapping leader to <nop>)
" let g:EasyMotion_do_mapping = 0

" For better performance (also doesnt make sense to search offscreen)
let g:EasyMotion_off_screen_search=0
" improve readability
let g:EasyMotion_use_upper = 1
let g:EasyMotion_keys = 'ASDGHKLQWERTYUIOPZXCVBNMFJ;'


" new separate bindings for each shortcut
nnoremap <Leader>w :call feedkeys("\<Plug>(easymotion-prefix)w")<CR>
nnoremap <Leader>e :call feedkeys("\<Plug>(easymotion-prefix)e")<CR>
nnoremap <Leader>b :call feedkeys("\<Plug>(easymotion-prefix)b")<CR>
nnoremap <Leader>j :call feedkeys("\<Plug>(easymotion-prefix)j")<CR>
nnoremap <Leader>k :call feedkeys("\<Plug>(easymotion-prefix)k")<CR>
" feedkeys will not work with xnore, will cancel selection.
xmap <Leader>w <Plug>(easymotion-prefix)w
xmap <Leader>e <Plug>(easymotion-prefix)e
xmap <Leader>b <Plug>(easymotion-prefix)b
xmap <Leader>j <Plug>(easymotion-prefix)j
xmap <Leader>k <Plug>(easymotion-prefix)k
" xnore <silent><leader>w :<c-u>:call feedkeys("\<Plug>(easymotion-prefix)w")<CR>

" -------------------- Auto-pairs
" WORKAROUND-AUTOPAIRS1 for the WORKAROUND-YCM1 below.
" We can either have correct results after <BS> *OR* removed brackets after <BS>
let g:AutoPairsMapBS=0

" Do not map space -> "(<space>T" will not result in "( T )" but in "( T)".
" Still a small price to pay for less bugs with completion plugins.
let g:AutoPairsMapSpace=0

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

" -------------------- Vim-surround
" s surrounds {move}, S surrounds line
let g:surround_no_mappings = 1
nmap s   <Plug>Ysurround
nmap S   <Plug>Yssurround
" ds mapping is already in place, but rebind as a reminder
nmap ds  <Plug>Dsurround
" cs mapping is already in place, but rebind as a reminder
nmap cs  <Plug>Csurround
xmap s   <Plug>VSurround

" -------------------- Eclim
" make eclim and ycm play nice, omnifunc mapping in insert mode is <c-x><c-o>
let g:EclimCompletionMethod = 'omnifunc'
" let g:EclimLogLevel = 'trace'

" -------------------- YouCompleteMe
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
" It will not re-trigger anything, but will not hide the usual vim menu.
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
" fuzzying is correct. This is possibly fixable with "g:ycm_semantic_triggers"
" but need to write python-style regex.

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
" ------------------------------------------------------------------------------

" " always show gutter(sign column)
augroup AlwaysShowGutterDDD
	autocmd!
	autocmd BufEnter * sign define dummy
	autocmd BufEnter * execute 'sign place 999999 line=1 name=dummy buffer=' . bufnr('')
augroup END

" ------------------ Neocomplete
" TODO: investigate the lag of pressing <space> between words. To test press:
" a a a a a a a a a a a a       and see the lag. Be in this vimrc, so that
" there are enough words otherwise there may be no visible lag.

inoremap <expr><c-space> pumvisible() ? "\<C-n>" : neocomplete#start_manual_complete()
inoremap <expr><s-space> pumvisible() ? "\<C-p>" : neocomplete#start_manual_complete()
set completeopt=menuone

" Autodetected value, to check if recognizes vimproc, or to manually disable
" using it.
" let g:neocomplete#use_vimproc

" Use neocomplete.
let g:neocomplete#enable_at_startup = 1

" disable automatic completion
let g:neocomplete#disable_auto_complete = 0
" TODO investigate whether it is the same as :NeoCompleteToggle

" When 1 more flicker, gives more correct results, when in autopopup mode.
" It seems like fuzzying is triggered when no candidates whose chars are matched
" consequently are not available. 1 always trigger fuzzying (it seems).
let g:neocomplete#enable_refresh_always = 0

" Use smartcase.
let g:neocomplete#enable_smart_case = 0

" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 2

" create delay before popup in ms (50 is default)
let g:neocomplete#auto_complete_delay = 500

" let g:neocomplete#skip_auto_completion_time = ''

" " Define keyword.
" if !exists('g:neocomplete#keyword_patterns')
" 	let g:neocomplete#keyword_patterns = {}
" endif
" let g:neocomplete#keyword_patterns['default'] = '\h\w*'
" " TODO check what exactly this does. Must be equivalent to:
" " let g:neocomplete#keyword_patterns._ = '\h\w*'

" if !exists('g:neocomplete#sources')
" 	let g:neocomplete#sources = {}
" endif

" " ---- for eclim
" " faq says it does not support eclim out of the box
" if !exists('g:neocomplete#force_omni_input_patterns')
" 	let g:neocomplete#force_omni_input_patterns = {}
" endif
" " then add one of the 2 following:
" " 1. from documentation:
" " let g:neocomplete#sources#omni#input_patterns.java =
" " \ \'\%(\h\w*\|)\)\.\w*

" " 2. but others seem to be using this
" " let g:neocomplete#force_omni_input_patterns.java = '\k\.\k*'
" " if !exists('g:neocomplete#sources#omni#input_patterns')
" " 	let g:neocomplete#sources#omni#input_patterns = {}
" " endif
" " let g:neocomplete#sources#omni#input_patterns.java = '\h\w*\.\w*'
" " ---------

" augroup NeocompleteDDD
" 	autocmd!
" 	autocmd VimEnter * call neocomplete#initialize()
" augroup END

" " <CR>: close popup and save indent.
" inoremap <silent> <CR> <C-r>=<SID>my_cr_function_DDD()<CR>
" function! s:my_cr_function_DDD()
"   return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
" endfunction

" " <TAB>: completion.
" inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

" neocomplete#start_manual_complete([{sources}])
" inoremap <expr><Tab>  neocomplete#start_manual_complete()

" " <C-h>, <BS>: close popup and delete backword char
" inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
" inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"

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

" -------------- KAORIYA --------------------------------------------
" REMINDER: always delete the included vimrc AND gvimrc files
if has('kaoriya')
	let g:no_gvimrc_example = 1
	set ambiwidth=auto
	" TODO check for existence vimrc and gvimrc and show error
endif

" " -------------- vim-shell --------------------------------------------
" " dont be always on top, so that alt-tabbing works
let g:shell_fullscreen_always_on_top = 0
" " dont use default mappings
let g:shell_mappings_enabled = 0
" " prevent airline's tab line from being hidden
let g:shell_fullscreen_items=''
" nnoremap <F11> :Fullscreen<CR>

" ------------ gvimfullscreen-win32 ----------------------------------
if has('win64')
	nnoremap <F11> <Esc>:call libcallnr(expand('$HOME\.vim\plugged\gvimfullscreen_win32\gvimfullscreen_64.dll'), "ToggleFullScreen", 0)<CR>
elseif has('win32')
	nnoremap <F11> <Esc>:call libcallnr(expand('$HOME\.vim\plugged\gvimfullscreen_win32\gvimfullscreen.dll'), "ToggleFullScreen", 0)<CR>
endif

" ---------------- profiling plugins
" https://stackoverflow.com/questions/12213597/how-to-see-which-plugins-are-making-vim-slow
" profile start profile.log | profile func * | profile file *
" " At this point do slow actions
" profile pause
" :qa
" ----------------- debugging autocmd -------------------------------
" While testing autocommands, you might find the 'verbose' option to be useful: >
" 	:set verbose=9
" This setting makes Vim echo the autocommands as it executes them.
" -------------------------------------------------------------------
" TODO beautify gutter sign error / warning
" -------------------------------------------------------------------
" TODO find a way to convert input to greek from vim, while still typing ENG
" -------------------------------------------------------------------
" for future fuzzy finder (like ctrlp)
" set wildignore+=*/build/**
