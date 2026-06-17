#!/usr/bin/env bash

set -eEuo pipefail

PATH=/usr/bin:/bin
export PATH

IFS=$' \t\n'

BIN_DIR="$HOME/.local/bin"
BIN_FILE="$BIN_DIR/pacman-zta"

STATE_DIR="$HOME/.local/share/pacman-zta"

BASH_COMPLETION_FILE="$HOME/.local/share/bash-completion/completions/pacman-zta"
ZSH_COMPLETION_FILE="$HOME/.local/share/zsh/site-functions/_pacman-zta"

BASH_COMPLETION_DIR="$(dirname "$BASH_COMPLETION_FILE")"
ZSH_COMPLETION_DIR="$(dirname "$ZSH_COMPLETION_FILE")"

# =====================================================
# ROOT CHECK
# =====================================================

if [[ "$EUID" -eq 0 ]]
then

    echo
    echo "ERROR: Do not run uninstall as root."
    echo

    exit 1

fi

# =====================================================
# REMOVE BINARY
# =====================================================

[[ -f "$BIN_FILE" ]] &&
    command rm -f "$BIN_FILE"

# =====================================================
# REMOVE COMPLETIONS
# =====================================================

command rm -f "$BASH_COMPLETION_FILE"
command rm -f "$ZSH_COMPLETION_FILE"

# =====================================================
# REMOVE STATE DIRECTORY
# =====================================================

if [[ -d "$STATE_DIR" ]]
then

    echo

    read -rp \
        "Remove $STATE_DIR ? [y/N] " \
        ANSWER

    if [[ "$ANSWER" =~ ^[Yy]$ ]]
    then

        while read -r FILE
        do

            [[ -z "$FILE" ]] && continue

            command rm -f "$FILE"

        done < <(

            command find \
                "$STATE_DIR" \
                -type f

        )

        rmdir "$STATE_DIR" 2>/dev/null || true

    fi

fi

# =====================================================
# REMOVE EMPTY COMPLETION DIRS
# =====================================================

if [[ -d "$BASH_COMPLETION_DIR" ]]
then

    if [[ -z "$(
        command find \
            "$BASH_COMPLETION_DIR" \
            -mindepth 1 \
            -print -quit
    )" ]]
    then

        echo

        read -rp \
            "$BASH_COMPLETION_DIR is empty. Remove it? [y/N] " \
            ANSWER

        [[ "$ANSWER" =~ ^[Yy]$ ]] &&
            rmdir "$BASH_COMPLETION_DIR"

    fi

fi

if [[ -d "$ZSH_COMPLETION_DIR" ]]
then

    if [[ -z "$(
        command find \
            "$ZSH_COMPLETION_DIR" \
            -mindepth 1 \
            -print -quit
    )" ]]
    then

        echo

        read -rp \
            "$ZSH_COMPLETION_DIR is empty. Remove it? [y/N] " \
            ANSWER

        [[ "$ANSWER" =~ ^[Yy]$ ]] &&
            rmdir "$ZSH_COMPLETION_DIR"

    fi

fi

# =====================================================
# REMOVE ~/.local/bin
# =====================================================

if [[ -d "$BIN_DIR" ]]
then

    if [[ -z "$(
        command find \
            "$BIN_DIR" \
            -mindepth 1 \
            -print -quit
    )" ]]
    then

        echo

        read -rp \
            "$BIN_DIR is empty. Remove it? [y/N] " \
            ANSWER

        if [[ "$ANSWER" =~ ^[Yy]$ ]]
        then

            rmdir "$BIN_DIR"

            echo
            echo "$BIN_DIR removed."

        fi

    else

        echo
        echo "$BIN_DIR contains other executables."
        echo "Keeping directory."
        echo
        echo "PATH entries in .bashrc and .zshrc were intentionally preserved."

    fi

fi

# =====================================================
# FINAL MESSAGE
# =====================================================

echo
echo "pacman-zta uninstalled."
echo
echo "No changes were made to:"
echo
echo "  ~/.bashrc"
echo "  ~/.zshrc"
echo
echo "Completion initialization and PATH entries were preserved."
echo
