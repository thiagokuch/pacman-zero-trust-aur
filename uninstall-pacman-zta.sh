#!/usr/bin/env bash

set -e

BIN_DIR="$HOME/.local/bin"

BIN_FILE="$BIN_DIR/pacman-zta"

STATE_DIR="$HOME/.local/share/pacman-zta"

BASH_COMPLETION_FILE="$HOME/.local/share/bash-completion/completions/pacman-zta"

ZSH_COMPLETION_FILE="$HOME/.local/share/zsh/site-functions/_pacman-zta"

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

if [[ -f "$BIN_FILE" ]]
then

    rm -f "$BIN_FILE"

fi

# =====================================================
# REMOVE COMPLETIONS
# =====================================================

rm -f "$BASH_COMPLETION_FILE"

rm -f "$ZSH_COMPLETION_FILE"

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

        rm -rf "$STATE_DIR"

    fi

fi

# =====================================================
# REMOVE EMPTY COMPLETION DIRECTORIES
# =====================================================

BASH_COMPLETION_DIR="$(dirname "$BASH_COMPLETION_FILE")"

ZSH_COMPLETION_DIR="$(dirname "$ZSH_COMPLETION_FILE")"

if [[ -d "$BASH_COMPLETION_DIR" ]]
then

    if [[ -z "$(find "$BASH_COMPLETION_DIR" -mindepth 1 -print -quit)" ]]
    then

        echo

        read -rp \
            "$BASH_COMPLETION_DIR is empty. Remove it? [y/N] " \
            ANSWER

        if [[ "$ANSWER" =~ ^[Yy]$ ]]
        then

            rmdir "$BASH_COMPLETION_DIR"
        fi

    fi

fi

if [[ -d "$ZSH_COMPLETION_DIR" ]]
then

    if [[ -z "$(find "$ZSH_COMPLETION_DIR" -mindepth 1 -print -quit)" ]]
    then

        echo

        read -rp \
            "$ZSH_COMPLETION_DIR is empty. Remove it? [y/N] " \
            ANSWER

        if [[ "$ANSWER" =~ ^[Yy]$ ]]
        then

            rmdir "$ZSH_COMPLETION_DIR"
        fi

    fi

fi

# =====================================================
# REMOVE ~/.local/bin
# =====================================================

if [[ -d "$BIN_DIR" ]]
then

    if [[ -z "$(find "$BIN_DIR" -mindepth 1 -print -quit)" ]]
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