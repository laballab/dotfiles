# Inpired by code found on exit signal hook on the zsh-prompt-powerline project
# see  https://github.com/Valodim/zsh-prompt-powerline/blob/master/hooks/prompt-exitnames.zsh
#
# This function replaces the exit status number with its associated signal name
# name. We can't know for sure if these return codes are actually caused by the
# signals, but usually they are, since few programs output exit codes > 128 for
# error conditions.
# If no matching codes then output code.


nice_exit_code() {
	local exit_status="${1:-$(print -P %?)}";

	# nothing to do here
	[[ -z $exit_status || $exit_status == 0 ]] && return;

	exit_status="[$exit_status]"
	echo "$ZSH_PROMPT_EXIT_SIGNAL_PREFIX%{$fg_bold[red]%}${exit_status} %{$reset_color%}$ZSH_PROMPT_EXIT_SIGNAL_SUFFIX";
}
