#compdef pacman-zta

# =====================================================
# 19-_pacman-zta
# =====================================================

local context state line

typeset -A opt_args

local -a commands
local -a packages

commands=(
    'install:Install package(s)'
    'remove:Remove package(s)'
    'update:Update managed packages'
    'status:Show package status'
    'list:List managed packages'
    'clean:Clean cache'
    'full-clean:Full cleanup'
    'audit:Audit package(s)'
    'audit-installed:Audit managed packages'
    'doctor:Verify dependencies and configuration'
    'version:Show version'
    'help:Show help'
)

_arguments \
    '1:command:->command' \
    '*::argument:->args'

case "$state" in

    command)

        _describe 'command' commands

        ;;

    args)

        case "$words[2]" in

            install|remove|audit|status)

                packages=(${(f)"$(pacman -Qq 2>/dev/null)"})

                _describe 'package' packages

                ;;

        esac

        ;;

esac
