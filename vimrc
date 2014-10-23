set nocompatible
" filetype plugins
filetype on
filetype indent on
filetype plugin on
syntax on
" auto read when a file is changed outside
set autoread
" 3 lines to the cursor
set scrolloff=3
set ruler
set cmdheight=2
" a buffer becomes hidden when it is abadoned
set hid
set number
" search related
set ignorecase
set smartcase
set hlsearch
set incsearch
" regular expressions turn magic on
set magic
" match brackets
set showmatch
set mat=2
" use spaces instead of tabs
set expandtab
" be smart for tabs
set smarttab
" 1 tab = 4 spaces
set shiftwidth=4
set tabstop=4
set list
set listchars=tab:»\ 

" always show the status line
set laststatus=2
set showcmd
set cursorline

" treat long lines as break lines
map j gj
map k gk

" resume position when reopen
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
