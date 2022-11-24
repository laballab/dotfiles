" .vimrc

" plugins
" --------------------------
call plug#begin()
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
  Plug 'wuelnerdotexe/vim-enfocado'
  Plug 'airblade/vim-gitgutter'
  Plug 'scrooloose/nerdtree'
  Plug 'xuyuanp/nerdtree-git-plugin'
  Plug 'tpope/vim-commentary'
  Plug 'ap/vim-buftabline'
  Plug 'mbbill/undotree'
  Plug 'itchyny/lightline.vim'
  Plug 'justinmk/vim-sneak'
  Plug 'voldikss/vim-floaterm'
  Plug 'psliwka/vim-smoothie'
  Plug 'tpope/vim-fugitive'
  Plug 'sheerun/vim-polyglot'
  Plug 'kmonad/kmonad-vim'
call plug#end()


" plugin configs
" --------------------------
" transparent background
augroup enfocado_customization
  autocmd!
    autocmd ColorScheme enfocado ++nested highlight Normal ctermbg=NONE guibg=NONE
augroup END
" lightline theme
function ShortBranch()
  let b = toupper(FugitiveHead())
  let bSplit = split(b,'/')
  if len(bSplit) > 0
    return bSplit[0]
  endif
  return b
endfunction
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'readonly', 'filename', 'modified' ] ],
      \   'right': [ [ 'percent' ],
      \              [ 'gitbranch' ],
      \              [ 'filetype', 'fileencoding' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'ShortBranch'
      \ },
      \ }
" ctrl-t tree view
nnoremap <C-t> :NERDTreeToggle<CR>
" disable fzf preview
let g:fzf_preview_window = []
" fzf hotkeys
nnoremap <C-p> :GFiles<Cr>
nnoremap <C-P> :Files<Cr>
nnoremap <C-o> :Buffers<Cr>
" custom icons for nerdtree git
let g:NERDTreeGitStatusIndicatorMapCustom = {
      \ 'Modified'  :'*',
      \ 'Staged'    :'+',
      \ 'Untracked' :'#',
      \ 'Renamed'   :'>',
      \ 'Unmerged'  :'=',
      \ 'Deleted'   :'~',
      \ 'Dirty'     :'☓',
      \ 'Ignored'   :'!',
      \ 'Clean'     :'✓',
      \ 'Unknown'   :'?',
      \ }

" ctrl+space for terminal toggle
nnoremap <C-Space> :FloatermToggle<Cr>
tnoremap <C-Space> <C-\><C-n>:FloatermToggle<Cr>


" other configs
" --------------------------
" terminal escape
tnoremap <Esc> <C-\><C-n>
" hide MODE status
set noshowmode
" enable vertical cursor when in insert mode
set guicursor=i:ver1
" enable cursor blinking
set guicursor+=a:blinkon1
" enable mouse support
set mouse=a
" enable line numbers
set number
set relativenumber
" search
set ignorecase
set smartcase
" backspace
set backspace=indent,eol,start
" wildmenu
set wildmode=longest,list,full
set wildmenu
" tab
set tabstop=2
set softtabstop=2
set shiftwidth=2
set shiftround
set expandtab
set smarttab
" indent
set autoindent

" enable colors & colorscheme
set t_Co=256
colorscheme enfocado
syntax on
set hidden

" fix buftab colors - must go after colorscheme
hi TabLine ctermfg=DarkGrey
