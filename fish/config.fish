set -x AWS_PROFILE product-newlexis-dev
set -x JAVA_HOME (/usr/libexec/java_home -v 11)
set -x sel ~/.config/nnn/.selection
set -x GOPATH {$HOME}/.go 
set -x GOROOT /usr/local/opt/go/libexec
set -x DLKEY PFueCQ7gKL2ZQCxLOBmuf34erUaGJUS08fKZfa2E
set -x EDITOR nvim

set -x FZF_DEFAULT_OPTS --height 24% --layout=reverse


function saml_refresh
  python3 /Users/ballablx/Documents/platformengineering_samlapi/saml.py -r 
end

function ncd --wraps nnn --description 'support nnn quit and change directory'
    if test -n "$NNNLVL"
        if [ (expr $NNNLVL + 0) -ge 1 ]
            echo "nnn is already running"
            return
        end
    end

    if test -n "$XDG_CONFIG_HOME"
        set -x NNN_TMPFILE "$XDG_CONFIG_HOME/nnn/.lastd"
    else
        set -x NNN_TMPFILE "$HOME/.config/nnn/.lastd"
    end

    # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
    # stty start undef
    # stty stop undef
    # stty lwrap undef
    # stty lnext undef

    nnn $argv
    if test -e $NNN_TMPFILE
        source $NNN_TMPFILE
        rm $NNN_TMPFILE
    end
end
