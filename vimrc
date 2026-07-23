" vi: foldmarker=[[[,]]] foldmethod=marker

" General [[[
set nocompatible
set backspace=indent,eol,start
filetype plugin indent on
syntax on
syntax sync fromstart

set history=1000
set hidden          " allow switching away from modified buffers
set autoread        " reload files changed outside vim
set gdefault        " :s substitutes all matches on a line by default
" ]]]

" UI / display [[[
set title
set ruler
set showcmd
set number
"set relativenumber " uncomment for relative line numbers
set cursorline
set so=5            " keep 5 lines of context around the cursor
set lz              " lazy redraw - won't redraw whilst running a macro
set novisualbell
set vb t_vb=        " no bell, no flash
set mouse=a
set splitbelow
set splitright
set updatetime=300
"set termguicolors  " enable in a true-colour terminal (iTerm2, etc.)

set laststatus=2
set statusline=%<Type:%Y\ %=ASCII:%b\ Column:%c\ Line:%l\ Where:%P
" ]]]

" Search [[[
set hlsearch
set incsearch
set ignorecase
set smartcase
" ]]]

" Indentation [[[
set ts=4
set sw=4
set expandtab
set smarttab
set autoindent
set smartindent
" ]]]

" Folding [[[
set foldenable
set foldmethod=marker
set foldcolumn=1
" ]]]

" Files / persistence [[[
set nobackup

" keep swap files out of project trees
if !isdirectory($HOME . '/.vim/swap')
    call mkdir($HOME . '/.vim/swap', 'p')
endif
set directory=~/.vim/swap//

" persistent undo - undo history survives closing a file
if !isdirectory($HOME . '/.vim/undo')
    call mkdir($HOME . '/.vim/undo', 'p')
endif
set undofile
set undodir=~/.vim/undo//
" ]]]

" Clipboard [[[
" yank/paste straight to the macOS system clipboard
set clipboard=unnamed
" ]]]

" Wildmenu / completion [[[
set wildmenu
set wildmode=list:longest,full
set wildignore=*~,*.o,CVS,*.pyc
set wildignorecase
" ]]]

" Matching [[[
" add more bracket types to the matchpairs list for highlighting purposes
set matchpairs+=<:>
set matchpairs+=[:]
" ]]]

" Autocommands [[[
augroup vimrcEx
    au!

    autocmd FileType text setlocal textwidth=78

    " jump to the last known cursor position when reopening a file
    autocmd BufReadPost *
      \ if line("'\"") > 0 && line("'\"") <= line("$") |
      \   exe "normal g`\"" |
      \ endif

    " highlight trailing whitespace and tabs on each line for ALL file types
    autocmd BufReadPost,BufNewFile * call SetTrailWS()

    autocmd BufReadPost,BufNewFile *
        \ if &filetype == "vim" | call MapVimKeys() | endif

    autocmd BufReadPost,BufNewFile *
        \ if &filetype == "cpp" | call SetCPP() | endif

    autocmd BufReadPost,BufNewFile *
        \ if &filetype == "python" | call SetPy() | endif
augroup END

"
" For git commits turn spell checking on. Use ]s [s to hop between errors and
" z= to bring up a list of potential corrections.
"
autocmd FileType gitcommit set spell
" ]]]

" Mappings [[[
" clear search highlight
nnoremap <silent> <Leader><Space> :nohlsearch<CR>

" maps \k to highlight the current line
nnoremap <silent> <Leader>k mk:exe 'match Search /<Bslash>%'.line(".").'l/'<CR>

" strip carriage returns from the whole file
map <F5> :call MyRmCR()<CR>

" %s is a bastered to type
map gs :%s/

nnoremap <F1> :help<Space>

" tab navigation (insert mode)
imap <F7> <ESC>:tabp
imap <F9> <ESC>:tabn

" tab navigation (command mode)
map <F7> <ESC>:tabp
map <F9> <ESC>:tabn
" ]]]

" Abbreviations [[[
ab #d #define
ab #i #include
ab serr std::cerr <<
ab sout std::cout <<
ab sendl std::endl
ab sstr std::string

" Simple spelling mistakes
ab teh the
" ]]]

" Colours [[[
"
" When running vimdiff set the colour scheme to something that makes diffs
" actually viewable
"
if &diff
    colorscheme delek
endif
" ]]]

" Functions [[[
function! MyRmCR()
    let oldline=line(".")
    exe ":%s/\r//g"
    exe ':' . oldline
endfunction

function! MapVimKeys(...)
    " comment the current line
    map <C-C> O"<SPACE><SPACE><ESC>i

    " open a code fold
    map <C-Z> O"  [<ESC>i[[<ESC>3hi

    " Close a code fold
    map <C-X> o" ]<ESC>i]]<ESC>
endfunction

function! SetTrailWS(...)
    syn match extraWhiteSpace /\s\+$\| \+\ze\t/
    hi def extraWhiteSpace ctermbg=blue guibg=blue

    syn match StupidTABS /\t/
    hi def StupidTABS ctermbg=green guibg=green
endfunction

function! SetPy(...)
    syn keyword pyBasicTypes dict set

    hi pyBasicTypesColour
        \ guifg=magenta guibg=NONE
        \ ctermfg=magenta ctermbg=NONE

    hi def link pyBasicTypes pyBasicTypesColour
endfunction

function! SetCPP(...)
    syn match       cppNamespaces       "\<std::\|\<boost::"

    hi cppNamespacesColours
        \ gui=bold guifg=red guibg=NONE
        \ cterm=bold ctermfg=red ctermbg=NONE

    hi def link cppNamespaces cppNamespacesColours

    " Comment the current line
    map <C-C> O/*  */<ESC>2hi

    " draw a comment separator
    map <F2> A/<Esc>78A*<Esc>A/<Esc>

    " draw a comment block and leave cursor primed for input
    map <F3> i/<ESC>68A*<ESC>4A<CR><ESC>67A*<ESC>A/<CR><ESC>3kA

    " Comment the current line
    map <F6> :s/^/\/\//g <CR> :noh <CR>

    " Uncomment the current line
    map <F7> :s/^\/\///g <CR> :noh <CR>

    " Open a code fold
    map <C-Z> O/*  {{{ */<ESC>6hi

    " Close a code fold
    map <C-X> o/* }}} */<ESC>
endfunction
" ]]]
