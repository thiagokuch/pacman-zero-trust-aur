# =====================================================
# completion.bash
# =====================================================

_pacman_zta()
{
    local cur prev

    COMPREPLY=()

    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    local commands="
install
remove
update
status
list
clean
full-clean
audit
audit-installed
doctor
version
help
"

    case "$COMP_CWORD" in

        1)

            COMPREPLY=(
                $(compgen -W "$commands" -- "$cur")
            )

            return

            ;;

    esac

    case "$prev" in

        install|remove|audit|status)

            COMPREPLY=(
                $(compgen -W "$(pacman -Qq 2>/dev/null)" -- "$cur")
            )

            return

            ;;

    esac

}

complete -F _pacman_zta pacman-zta
