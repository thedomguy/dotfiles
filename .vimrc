" Performance improvements
set lazyredraw          " Don't redraw while executing macros
set ttyfast             " Faster redrawing
set updatetime=300      " Faster completion
set timeoutlen=500      " Faster key sequence completion

" Add to your existing settings
set nocompatible

" ===============================================
" Vim-Plug Plugin Manager
" ===============================================
call plug#begin('~/.vim/plugged')

" FZF and its Vim integration
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Optional: Better file icons (requires a patched font)
" Plug 'ryanoasis/vim-devicons'

" LSP and code completion
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Utility plugins
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'

call plug#end()

filetype plugin indent on
syntax on
set number relativenumber
set shiftwidth=4
set tabstop=4
set expandtab
set nobackup
set scrolloff=10
set nowrap
set incsearch
set ignorecase
set smartcase           " Override ignorecase when search includes uppercase
set clipboard=unnamed,unnamedplus

" Define leader key (default is backslash \)
let mapleader = "\\"

" WebStorm-like 'select next occurrence' feature
" In normal mode: searches for the word under cursor and selects it
" In visual mode: finds and selects the next occurrence
" Use <leader>j (by default \j) instead of Cmd+J for better terminal compatibility
nnoremap <leader>j *Ngn
xnoremap <leader>j gn
" Alternative mapping using Alt+J for terminals that support it
nnoremap <A-j> *Ngn
xnoremap <A-j> gn

" ===============================================
" CoC (LSP) Configuration
" ===============================================
" To install language servers: :CocInstall coc-tsserver coc-eslint coc-prettier coc-json
let g:coc_global_extensions = [
  \ 'coc-tsserver',
  \ 'coc-eslint',
  \ 'coc-prettier',
  \ 'coc-json',
  \ ]

" Key mappings for CoC
" Go to definition
nmap <silent> gd <Plug>(coc-definition)
" Go to type definition
nmap <silent> gy <Plug>(coc-type-definition)
" Go to implementation
nmap <silent> gi <Plug>(coc-implementation)
" Find references
nmap <silent> gr <Plug>(coc-references)
" Show documentation on hover
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" ===============================================
" FZF Configuration for WebStorm-like file search
" ===============================================
" Enable FZF in Vim
" WebStorm-like keyboard shortcuts
" Ctrl+Shift+N or Cmd+Shift+O for file search (use Ctrl+P as primary)
nnoremap <C-p> :FZF<CR>
nnoremap <leader>f :FZF<CR>

" Search in files (like Ctrl+Shift+F in WebStorm)
nnoremap <leader>s :Rg<CR>

" FZF window configuration
let g:fzf_layout = { 'down': '~40%' }

" Customize FZF colors to match your theme
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

" Custom FZF command to respect .gitignore and show hidden files
let $FZF_DEFAULT_COMMAND = 'fd --type f --hidden --follow --exclude .git'

" Advanced file search with preview
command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

" Use Files command for better file search
nnoremap <C-p> :Files<CR>

" Recent files (like WebStorm's recent files)
nnoremap <leader>r :History<CR>

" Search in open buffers
nnoremap <leader>b :Buffers<CR>
