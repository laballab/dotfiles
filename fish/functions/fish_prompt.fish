function fish_prompt --description 'Write out the prompt'
  set -g __fish_git_prompt_showdirtystate
  set -g __fish_git_prompt_use_informative_chars

  set -l last_status $status
  set -l last_status_color "green"

  if test $last_status -ne 0
    set last_status_color "red"
  end

  echo -s -e (set_color yellow) (whoami) " " \
    (set_color $fish_color_cwd) (prompt_pwd) \
    (set_color cyan) (__fish_git_prompt) \
    (set_color $last_status_color) "\n["$last_status"]" (set_color --bold 585A65) " >> "
end
