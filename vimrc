" NeoBundle init
if !1 | finish | endif

if has('vim_starting')
   if &compatible
     set nocompatible               " Be iMproved
   endif

" Required:
set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

" Required:
call neobundle#begin(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

" My Bundles here:
" Refer to |:NeoBundle-examples|.
" Note: You don't set neobundle setting in .gvimrc!

" Themes, also check end of this file for mappings
NeoBundle 'nanotech/jellybeans.vim'     " jellybeans theme
NeoBundle 'morhetz/gruvbox'             " gruvbox theme
NeoBundle 'dimxdim/jellybat'             " jellybat theme
NeoBundle 'chriskempson/base16-vim'
NeoBundle 'vim-scripts/Wombat'
NeoBundle 'vim-scripts/wombat256.vim'
" NeoBundle 'vim-scripts/SyntaxAttr.vim' "check syntax group under cursor <F11>
" NeoBundle 'gerw/vim-HiLinkTrace' "check all possible syntax groups under cursor <F10>
" NeoBundle 'guns/xterm-color-table.vim' "print color table with corresp color codes <F9>
" NeoBundle 'lilydjwg/colorizer' "print color table with corresp color codes <F8>

" Serious plugins
"NeoBundle 'matchit.zip'
NeoBundle 'bling/vim-airline'
NeoBundle 'dimxdim/vim-airline-loclist'
NeoBundle 'jiangmiao/auto-pairs'
NeoBundle 'tpope/vim-surround'
NeoBundle 'tpope/vim-commentary'
NeoBundle 'tommcdo/vim-exchange'
NeoBundle 'Lokaltog/vim-easymotion'
NeoBundle 'Valloric/YouCompleteMe'

call neobundle#end()

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck


"" System general settings
set shortmess+=I                                    " disable start message
set mouse=a                                         "enable mouse
set encoding=utf-8                                  "set encoding for text
set ttyfast                                         "assume fast terminal connection, fast redraws
set hidden                                          "allow buffer switching without saving
set fileformats+=mac                                "add mac to auto-detection of file format line endings
set nrformats-=octal                                "always assume decimal/hex numbers

"" Visual general settings
set showcmd             " show (partial) command in bottom-right
set number              " show line numbers
syntax on           " syntax enable syntax processing, *syntax on* overrides with defaults!
set showmatch           " highlight matching [{()}]
set scrolloff=200		" no. of lines shown above/below cursor, large no. will always have cursor in middle

"" Tabs and spaces
"set tabstop=4       " number of visual spaces per TAB
"set softtabstop=4   " number of spaces in tab when editing
"set shiftwidth=4    " for indentation command in normal mode
"set expandtab       " tabs are spaces
"set shiftround    " use multiple of shiftwidth when indenting with '<' and '>'
set backspace=indent,eol,start      "allow backspacing everything in insert mode
set list                 "highlight whitespace
set listchars=tab:│\ ,trail:•,extends:❯,precedes:❮,nbsp:■	" whitespaces to show (tab:│\ old, ▸\ new)
"set shiftround			" Round indent to multiple of 'shiftwidth'. +Applies to > and <
"set smarttab		" insert blanks according to shiftwidth (else tabstop or softtabstop)
set wrap            " wrap text on eol (default)
let &showbreak='↪ '	" Char to signify line break
set autoindent		" The simplest automatic indent

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

" GUI
if has('gui_running')
	"set guicursor=n-v-c:blinkon0-block-Cursor/lCursor,ve:ver35-Cursor,o:hor50-Cursor,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor,sm:block-Cursor-blinkwait175-blinkoff150-blinkon175 "dont blink
	let &guicursor = substitute(&guicursor, 'n-v-c:', '&blinkon0-', '')
	"set guicursor=
	"set lines=999 columns=9999  " open maximized
	set guioptions-=t                                 "no tear off menu items
	set guioptions+=c                                 "no gui dialogs
	set guioptions-=T                                 "no toolbar icons
	set guioptions-=r                                   " no right scrollbar
	set guioptions-=l           " no left scrollbar
	set guioptions-=L           " no left scrollbar when vert. split
	set guioptions-=m           " no menu
	set guifont=MonaVu\ 10
else
	set t_Co=256			" terminal colors 256
endif

colorscheme jellybat

"" Special highlight of 81st char in long line (from TARBALL)
highlight MyColorColumn guifg=#d8d8d8 guibg=#ab4642 guisp=NONE gui=NONE ctermfg=7 ctermbg=1 cterm=NONE
call matchadd('MyColorColumn', '\%81v', 100)

" Key remaps
" Swap : and ; to make colon commands easier to type
" The vice versa remapping *may* break plugins - to be confirmed
nnoremap  ;  :
"nnoremap  :  ;
xnoremap  ;  :
"xnoremap  :  ;

" map leader key to , find char again \, find char again backwards |
" another option is "map <Space> <Leader>" but will not trigger double leader
" aka <Leader><Leader> mappings
" let mapleader = "\<Space>" if let mapleader = " " doesnt work
" also if remapped leader is continuously pressed, next leader presses will
" not be triggered until modes are changed (easymotion probably is culprit)
nnoremap <Space> <Nop>
xnoremap <Space> <Nop>
"let mapleader = " "
let mapleader = "\<Space>"

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
xnoremap p "_dP
" now also indents the pasted text - a bit twitchy/flashing due to reselection
"xnoremap p "_dPV`]=
" that's why we use =`]
" (`] marker-motion == jump to end to previously changed/yanked text)
"
" xnoremap p "_dP=`]
" nnoremap p p=`]

" x in normal or visual will not overwrite the paste buffer
nnoremap x "_x
xnoremap x "_x

" X deletes to black hole till end of line
nnoremap X "_D

" Y yanks till end of line, instead of whole line
nnoremap Y y$

" Stop highlighting matching search pattern pressing <ESC>
" BEGIN_WORKAROUND
	" needs <esc>smth mapped in order to trigger timeout.
	" only then it will work. else numbers on startup in terminal.
	" also, rapid pressing <esc><F*> will result in weird behavior, such
	" as entering insert mode and writing S for <esc><F4>.
	" Triple esc mapping prevents it
		nnoremap <silent> <ESC> :nohlsearch<CR><ESC>
		nnoremap <silent> <ESC><ESC> :nohlsearch<CR><ESC>
		nnoremap <silent> <ESC><ESC><ESC> :nohlsearch<CR><ESC>
" END_WORKAROUND

" GUI doesnt need workaround, so lets not add delay of <esc><esc>.
if has('gui_running')
	unmap <silent> <ESC><ESC>
	unmap <silent> <ESC><ESC><ESC>
	nnoremap <silent> <ESC> :nohlsearch<CR><ESC>
endif

"====[ Swap V and CTRL-v. Regular visual is now Shift-v. ]======
"====[ Block mode is more useful that Visual mode ]======
nnoremap    v   <C-V>
xnoremap    v   <C-V>
nnoremap <C-V>     V
xnoremap <C-V>     V
nnoremap    V   v
xnoremap    V   v

" move to beginning/end of line (also consider B and E as alternative)
" <C-H> by default in terminal is produced by backspace
" TODO: find suitable shortcut for moving to beginning in insert mode
noremap <C-H> ^
noremap <C-L> $
" <C-L> appends to end of line, useful to escape auto-closing parens
inoremap <silent><C-L> <ESC><ESC>A
" command mode move to beginning/end
cnoremap <C-A> <Home>
cnoremap <C-L> <End>

"TODO insert and append to each line when in visual
"xnoremap i I <-- inside
" unmap a% <-- matchit plugin maps a%, causing delay when 'a'
"xnoremap a A <-- around

" c-d exits, c-s writes(if buffer was modified), c-c deletes buffer
nnoremap <C-D> :q<CR>
nnoremap <silent><C-S> <ESC><ESC>:update<CR><ESC>
inoremap <silent><C-S> <ESC><ESC>:update<CR><ESC>
nnoremap <silent><C-C> :bdelete<CR>

" <leader>s performs substitution
nnoremap <Leader>s :%s//<left>

" In visual search for current selection to make it substitution target,
" <c-u> needed to remove '<'> of visual
" xmap to use * custom binding (and not the default of xnoremap)
xmap <Leader>s *:<C-u>%s//

" Reselect pasted text linewise
nnoremap <Leader>v `[V`]

" Reselect pasted text linewise, ( `[ is jump to beginning of changed/yanked )
nnoremap <Leader>v `[V`]

" Uppercase current word in norm/insert (k for kefalaia)
nnoremap <C-k> gUiw
" Should not use c-u, conflicts with ycm
inoremap <C-k> <ESC>gUiwea
noremap <C-u> <nop>

" Jump a word forward in insert mode
inoremap <C-e> <ESC>ea
" Jump a word back in insert mode
inoremap <C-b> <ESC>bi

"====[ '*' in visual will do search on selection - the correct way ]======
xnoremap * :<C-u>call <SID>VSetSearch()<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u>call <SID>VSetSearch()<CR>?<C-R>=@/<CR><CR>
function! s:VSetSearch()
  let temp = @s
  norm! gv"sy
  let @/ = '\V' . substitute(escape(@s, '/\'), '\n', '\\n', 'g')
  let @s = temp
endfunction

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
endif

" TODO:
" Find mappings for the following actions
" - command mode paste "+ register

"========================================= PLUGIN SETTINGS =====================
"{{{
    " let g:airline#extensions#loclist#enabled = 1
    let g:airline#extensions#tabline#enabled = 1
    let g:airline_powerline_fonts = 1
    let g:airline#extensions#eclim#enabled = 1
    " let g:airline#extensions#syntastic#enabled = 1
    set laststatus=2    " Always show status bar
"}}}

let g:ycm_always_populate_location_list = 1
" auto close preview after leaving insert mode
let g:ycm_autoclose_preview_window_after_insertion = 1
" stop highlighting warning/error parts of line, causes highlighing at the
" same point in all the other open buffers
let g:ycm_enable_diagnostic_highlighting = 0

" make eclim and ycm play nice
let g:EclimCompletionMethod = 'omnifunc'

" Easymotion : Use original mappings - may break plugins
" TODO manually bind only those shortcuts that i use
map <Leader> <Plug>(easymotion-prefix)
" for better performance (also doesnt make sense to search offscreen)
let g:EasyMotion_off_screen_search=0

" WORKAROUND1 FOR https://github.com/Valloric/YouCompleteMe/issues/526
" When using <BS> completion results change and become fewer.
" <C-w> to begin typing again will give correct results, but maybe not worth
" retyping. This will most likely break deletion in any pair auto close plugins.
inoremap <expr><BS> pumvisible()? "\<C-y>\<BS>" : "\<BS>"

" WORKAROUND2 for the workaround above, this time in auto-pairs
" We can either have correct results after <BS> *OR* removed brackets after <BS>
let g:AutoPairsMapBS=0

" c-x marks for exchange in visual-only, default (X aka black hole delete) also remains
" (manual suggests xmap, doesnt say anything about xnoremap)
xmap <C-X> <Plug>(Exchange)

" surround.vim mappings
" s surrounds {move}, S surrounds line
let g:surround_no_mappings = 1
nmap s   <Plug>Ysurround
nmap S   <Plug>Yssurround
nmap ds  <Plug>Dsurround
nmap cs  <Plug>Csurround
xmap s   <Plug>VSurround

" make any scratch/preview windows during insertion (completion) show below (bottom)
augroup PreviewOnBottom
	autocmd!
	autocmd InsertEnter * set splitbelow
	autocmd InsertLeave * set splitbelow!
augroup END

" always show gutter(sign column)
augroup AlwaysShowGutter
	autocmd!
	autocmd BufEnter * sign define dummy
	autocmd BufEnter * execute 'sign place 999999 line=1 name=dummy buffer=' . bufnr('')
augroup END

"============== mappings of <F>'s

" enter paste mode on pressing F4, to stop autoindenting etc, not needed when
" using "+ register -- to be confirm
set pastetoggle=<F4>
" for saving (writing out) as root - small delay on w in command line
cmap <F12> w !sudo tee % >/dev/null
" F's for plugins
nnoremap <F11> :call SyntaxAttr()<CR>
nnoremap <F10> :HLT<CR>
" for compiling and running and returning, F8 provides templates, F9 runs
nnoremap <F8> :nnoremap <F9> :!clear && make && ./CHANGE_ME && read -n 1\<lt>cr>
nnoremap <F9> :!clear && make && ./EXEC_NAME && read -n 1<cr>
"nnoremap <F9> :XtermColorTable<CR>
"nnoremap <F8> :ColorToggle<CR>
