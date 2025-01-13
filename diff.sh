#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

chk_diff() {
  echo $(printf %60s |tr ' ' '-')
  echo "! DIFF -> $1/$2"
  echo $(printf %60s |tr ' ' '-')
  diff --color ~/${3:-.}/$2 $SCRIPT_DIR/$1/$2
  echo '! DONE'
}

# check shell config & theme
chk_diff zsh .zshrc
chk_diff zsh/oh-my-zsh/themes bureau.zsh-theme .oh-my-zsh/themes

# check vim config
chk_diff vim .vimrc

# check tmux config
chk_diff tmux .tmux.conf


