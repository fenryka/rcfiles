" vi: foldmarker=[[[,]]]

set nocompatible
set backspace=indent,eol,start

filetype plugin indent on

"
" When running vimdiff set the colour scheme to something that makes diffs
" actually viewable
"
if &diff
  colorscheme delek
endif

augroup vimrcEx
au!

autocmd FileType text setlocal textwidth=78

autocmd BufReadPost *
  \ if line("'\"") > 0 && line("'\"") <= line("$") |
  \   exe "normal g`\"" |
  \ endif

  " highlight trailing whitespace and tabs on each line for ALL file types
  autocmd BufReadPost,BufNewFile * call SetTrailWS()

  autocmd BufReadPost,BufNewFile *
      \ if &filetype == "vim" |
      \   call MapVimKeys() | 
      \ endif

  autocmd BufReadPost,BufNewFile *
      \ if &filetype == "cpp" | call SetCPP() | endif

  autocmd BufReadPost,BufNewFile *
      \ if &filetype == "python" | call SetPy() | endif

augroup END

"
" For git commits turn spell checking on use ]s [s to hop between erros and z= to
" bring up a list of potential corrections
"
autocmd FileType gitcommit set spell

syntax on
set hlsearch
set ts=4
set sw=4
set expandtab
set nobackup
set smarttab
set vb t_vb=
set ttyfast
set title
set ignorecase
set smartcase
set lz " lazy redraw - won't redraw whilst running a macro
set lsp=0
set so=5
set history=50
set ruler
set showcmd
set incsearch

set foldenable
set foldmethod=marker
set foldcolumn=1
set novisualbell
set gdefault

set autoindent
set smartindent

set wildmenu
set wildmode=list:longest,full
set wildignore=*~,*.o,CVS,*.pyc
set showcmd
set showmode

set nobackup

set laststatus=2
set statusline=%<Type:%Y\ %=ASCII:%b\ Column:%c\ Line:%l\ Where:%P

" maps \k to highlight the current line
nnoremap <silent> <Leader>k mk:exe 'match Search /<Bslash>%'.line(".").'l/'<CR>

" add more bracket types to the matchpairs list for
" highlighting purposes
set matchpairs+=<:>
set matchpairs+=[:]

function! MyRmCR()
    let oldline=line(".")
    exe ":%s/\r//g"
    exe ':' . oldline
endfunction
map <F5> :call MyRmCR()<CR>

" %s is a bastered to type
map gs :%s/

nnoremap <F1> :help<Space>

" insert mode mapping
imap <F7> <ESC>:tabp
imap <F9> <ESC>:tabn

" command mode mapping
map <F7> <ESC>:tabp
map <F9> <ESC>:tabn

" Setup some simple abreviations
ab #d #define
ab #i #include
ab serr std::cerr <<
ab sout std::cout <<
ab sendl std::endl
ab sstr std::string

" Simple spelling mistakes 
ab teh the

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Auto commands
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

augroup vim_markup
augroup END

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Functions
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! MapVimKeys(...)
    " comment the current line
    map <C-C> O"<SPACE><SPACE><ESC>i

    " open a code fold
    map <C-Z> O"  [<ESC>i[[<ESC>3hi

    " Close a code fold
    map <C-X> o" ]<ESC>i]]<ESC>
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! SetTrailWS(...)
    "echo "SetTrailWS"
    syn match extraWhiteSpace /\s\+$\| \+\ze\t/
    hi def extraWhiteSpace ctermbg=blue guibg=blue

    syn match StupidTABS /\t/
    hi def StupidTABS ctermbg=green guibg=green
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! SetPy(...)
    syn keyword pyBasicTypes dict set 

    hi pyBasicTypesColour
        \ guifg=magenta guibg=NONE
        \ ctermfg=magenta ctermbg=NONE

    hi def link pyBasicTypes pyBasicTypesColour

endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! SetCPP(...)
    "echo "SetCPP"
    syn keyword     apfBasicTypes       sString sInstant sList
                                        \ sAssoc smart_ptr AddressList
                                        \ AbstractDescriptor
                                        \ CriticalSection s_instant_t
                                        \ AtomicValue AtomicBool
                                        \ AtomicInt AtomicCounter
                                        \ Condition sSmartPtr sDuration
                                        \ sInstant auto_ptr

    syn keyword     apfAutoTypes        AutoStack AutoLock sAutoLock
                                        \ safe_lock unsafe_lock
                                        \ AutoTryLock

    syn keyword     apfDebugTypes       s_assert QE_DBG
    syn keyword     apfCastTypes        tmp_64bit_cast sp_dynamic_cast
    syn keyword     apfBooleanTypes     true false
    syn keyword     apfIteratorTypes    iterator const_iterator sAssocIter

    syn match       cppNamespaces       "\<std::\|\<boost::"
    syn match       myNamespaces        "\<store::\|\<common::\|\<njal::\|\<list::"

    " Custom highlighting 
    hi apfBasicColor
        \ guifg=magenta guibg=NONE
        \ ctermfg=magenta ctermbg=NONE

    hi apfDebugColours 
        \ guifg=cyan guibg=NONE
        \ ctermfg=cyan ctermbg=NONE

    hi apfBooleanColours
        \ gui=bold guifg=red
        \ term=bold cterm=bold ctermfg=red

    hi cppNamespacesColours
        \ gui=bold guifg=red guibg=NONE
        \ cterm=bold ctermfg=red ctermbg=NONE

    hi myNamespacesColours
        \ gui=bold guifg=DarkMagenta guibg=NONE
        \ cterm=bold ctermfg=DarkMagenta ctermbg=NONE

    " Link the keyword groups to colour mappings 
    hi def link apfBasicTypes apfBasicColor
    hi def link apfAutoTypes Special
    hi def link apfDebugTypes apfDebugColours
    hi def link apfCastTypes cppStatement
    hi def link apfBooleanTypes apfBooleanColours

    hi def link cppNamespaces cppNamespacesColours
    hi def link myNamespaces myNamespacesColours
    hi def link apfIteratorTypes Type

    " Key mappings [[[

    " Comment the current line
    map <C-C> O/*  */<ESC>2hi

    " draw a comment seperator
    "map <F2> A/<Esc>68A*<Esc>A/<Esc>
    map <F2> A/<Esc>78A*<Esc>A/<Esc>

    " draw a comment block and leave curser primed for
    " input
    map <F3> i/<ESC>68A*<ESC>4A<CR><ESC>67A*<ESC>A/<CR><ESC>3kA 

    " Comment the current line
    map <F6> :s/^/\/\//g <CR> :noh <CR>

    " Uncomment the current line
    map <F7> :s/^\/\///g <CR> :noh <CR>

    " Open a code fold
    map <C-Z> O/*  {{{ */<ESC>6hi

    " Close a code fold
    map <C-X> o/* }}} */<ESC>

    " ]]]

endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

syntax sync fromstart

