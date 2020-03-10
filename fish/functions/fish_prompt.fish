function fish_prompt --description 'Write out the prompt'
	if not set -q __git_cb
    		set __git_cb (set_color cyan)":"(git branch ^/dev/null | grep \* | sed 's/* //')
    	end
	if test -z $WINDOW
        printf '%s%s%s%s%s%s%s%s%s%s%s' (set_color yellow) (whoami) (echo -n '@') (set_color purple) (echo -n 'MBP') (set_color $fish_color_cwd) (prompt_pwd) $__git_cb (set_color --bold 585A65) (echo -n '>>') (set_color normal)
    else
        printf '%s%s%s%s%s%s%s(%s)%s%s%s%s> ' (set_color yellow) (whoami) (set_color brwhite) (echo -n '@') (set_color purple) (echo -n 'MBP') (set_color white) (echo $WINDOW) (set_color $fish_color_cwd) (prompt_pwd) $__git_cb (set_color normal)
    end
end
