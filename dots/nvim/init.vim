set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
source ~/.vimrc

if has('nvim')
lua << EOF
  pcall(require, 'plugins')
  pcall(require, 'lsp')
EOF
endif
