

" :::      .::.  :::  .        :     :::::::..     .,-:::::  
" ';;,   ,;;;'   ;;;  ;;,.    ;;;    ;;;;``;;;;  ,;;;'````'  
"  \[[  .[[/     [[[  [[[[, ,[[[[,    [[[,/[[['  [[[         
"   Y$c.$$"      $$$  $$$$$$$$"$$$    $$$$$$c    $$$         
"    Y88P        888  888 Y88" 888o   888b "88bo,`88bo,__,o, 
"     MP         MMM  MMM  M'  'MMM   MMMM   'W"   `YUMMMMMP"


" --------------------------
" plugins
" --------------------------

" install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" run 'PlugInstall' if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source ~/.vimrc
\| endif

" list of plugins to install & load
call plug#begin()
" git
  Plug 'tpope/vim-fugitive'
  Plug 'rbong/vim-flog'
" fzf
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
" fern
  Plug 'lambdalisue/fern.vim'
  Plug 'lambdalisue/fern-hijack.vim'
  Plug 'lambdalisue/fern-git-status.vim'
  Plug 'lambdalisue/fern-renderer-nerdfont.vim'
  Plug 'lambdalisue/glyph-palette.vim'
  Plug 'lambdalisue/nerdfont.vim'
" front-end
  Plug 'wuelnerdotexe/vim-enfocado'
  Plug 'airblade/vim-gitgutter'
  Plug 'itchyny/lightline.vim'
  Plug 'voldikss/vim-floaterm'
  Plug 'psliwka/vim-smoothie'
  Plug 'mhinz/vim-startify'
  Plug 'wfxr/minimap.vim'
" utils
  Plug 'junegunn/vim-peekaboo'
  Plug 'sheerun/vim-polyglot'
  Plug 'tpope/vim-commentary'
  Plug 'justinmk/vim-sneak'
  Plug 'kmonad/kmonad-vim'
  Plug 'wincent/terminus'
  Plug 'mbbill/undotree'
call plug#end()


" --------------------------
" plugin configs
" --------------------------

" start page header
let g:startify_custom_header = [
    \ '           __                 ',
    \ '   __  __ /\_\    ___ ___     ',
    \ '  /\ \/\ \\/\ \ /` __` __`\   ',
    \ '  \ \ \_/ |\ \ \/\ \/\ \/\ \  ',
    \ '   \ \___/  \ \_\ \_\ \_\ \_\ ',
    \ '    \/__/    \/_/\/_/\/_/\/_/ ',
    \ '                              ',
    \ ]                             

" disable auto dir-change
let g:startify_change_to_dir = 0

" transparent background
augroup enfocado_customization
  autocmd!
    autocmd ColorScheme enfocado highlight Normal ctermbg=NONE guibg=NONE
augroup END

" enable smooth scrolling
let g:smoothie_experimental_mappings = 1

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
      \   'left':  [['mode', 'paste'],
      \             ['readonly', 'filename', 'modified']],
      \   'right': [['percent'      ],
      \             ['gitbranch'    ],
      \             ['filetype', 'fileencoding']]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'ShortBranch'
      \   },
      \ }

" fern configs
let g:fern#renderer = "nerdfont"
let g:fern#drawer_width = 21
let g:fern#hide_cursor = 1
let g:fern#renderer#nerdfont#indent_markers = 1
augroup fern_group
  autocmd!
    autocmd FileType fern setlocal norelativenumber | setlocal nonumber | call glyph_palette#apply()
augroup END
nnoremap <C-N> :Fern . -drawer -toggle -reveal=%<Cr>

" gitgutter configs
if has('nvim')
  let g:gitgutter_highlight_linenrs = 1
endif
nnoremap <C-K> :GitGutterToggle<Cr>

" disable fzf preview
let g:fzf_preview_window = []
" open fzf window from bottom
let g:fzf_layout = { 'window': { 'width': 1, 'height': 0.4, 'yoffset': 1.0 } }

" fzf hotkeys
" nnoremap <C-p> :GFiles<Cr>
nnoremap <C-P> :Files<Cr>
nnoremap <C-J> :Buffers<Cr>
nnoremap <C-H> :Commands<Cr>

" ctrl+space for terminal toggle
let g:floaterm_wintype = "split"
let g:floaterm_height = 0.4
nnoremap <C-Space> :FloatermToggle<Cr>
tnoremap <C-Space> <C-\><C-n>:FloatermToggle<Cr>

" minimap
let g:minimap_width = 8
let g:minimap_git_colors = 1
let g:minimap_block_buftypes = ['help', 'nofile', 'nowrite', 'quickfix', 'terminal', 'prompt']

" flog format
let g:flog_permanent_default_opts = {
    \ 'date': 'short',
    \ }


" --------------------------
" vim configs
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

" enter to insert newlines
nnoremap <Enter> o<ESC>
nnoremap <S-Enter> O<ESC>

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

" split below by default
set splitbelow

" speed up screen updates
set updatetime=500

" enable colors & colorscheme
set t_Co=256
set termguicolors
syntax on
set hidden
set background=dark
colorscheme enfocado
hi Floaterm guibg=NONE
hi FloatermNC guibg=NONE

" apply theme above to fzf-colors
let g:fzf_colors = {
  \ 'fg':      ['fg', 'Normal' ],
  \ 'bg':      ['bg', 'Normal' ],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'  ],
  \ 'info':    ['fg', 'PreProc'    ],
  \ 'border':  ['fg', 'Ignore'     ],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'  ],
  \ 'marker':  ['fg', 'Keyword'    ],
  \ 'spinner': ['fg', 'Label'      ],
  \ 'header':  ['fg', 'Comment'    ]}

" terminal colors
if has('nvim')
  let g:terminal_color_0  = '#1d1d1d'
  let g:terminal_color_1  = '#ed333b'
  let g:terminal_color_2  = '#57e389'
  let g:terminal_color_3  = '#ff7800'
  let g:terminal_color_4  = '#62a0ea'
  let g:terminal_color_5  = '#9141ac'
  let g:terminal_color_6  = '#5bc8af'
  let g:terminal_color_7  = '#deddda'
  let g:terminal_color_8  = '#9a9996'
  let g:terminal_color_9  = '#f66151'
  let g:terminal_color_10 = '#8ff0a4'
  let g:terminal_color_11 = '#ffa348'
  let g:terminal_color_12 = '#99c1f1'
  let g:terminal_color_13 = '#dc8add'
  let g:terminal_color_14 = '#93ddc2'
  let g:terminal_color_15 = '#f6f5f4'
else
  let g:terminal_ansi_colors = [
    \ '#1d1d1d', '#ed333b', '#57e389', '#ff7800',
    \ '#62a0ea', '#9141ac', '#5bc8af', '#deddda',
    \ '#9a9996', '#f66151', '#8ff0a4', '#ffa348',
    \ '#99c1f1', '#dc8add', '#93ddc2', '#f6f5f4'
  \ ]
endif

