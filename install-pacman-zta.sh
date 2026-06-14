#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

BIN_DIR="$HOME/.local/bin"
BIN_FILE="$BIN_DIR/pacman-zta"

BASH_COMPLETION_DIR="$HOME/.local/share/bash-completion/completions"
ZSH_COMPLETION_DIR="$HOME/.local/share/zsh/site-functions"

# =====================================================
# ROOT CHECK
# =====================================================

if [[ "$EUID" -eq 0 ]]
then

    echo
    echo "ERROR: Do not run install as root."
    echo

    exit 1

fi

# =====================================================
# DEPENDENCIES
# =====================================================

MISSING=()

for CMD in \
    git \
    curl \
    jq \
    shellcheck \
    namcap
do

    command -v "$CMD" >/dev/null 2>&1 || MISSING+=("$CMD")

done

if (( ${#MISSING[@]} > 0 ))
then

    echo
    echo "Missing dependencies detected."
    echo
    echo "Install them with:"
    echo
    echo "sudo pacman -S ${MISSING[*]}"
    echo
fi

# =====================================================
# DIRECTORIES
# =====================================================

mkdir -p "$BIN_DIR"
mkdir -p "$BASH_COMPLETION_DIR"
mkdir -p "$ZSH_COMPLETION_DIR"

# =====================================================
# BUILD
# =====================================================

echo
echo "Building pacman-zta..."
echo

mapfile -t MODULES < <(
    find "$SCRIPT_DIR" \
        -maxdepth 1 \
        -name '[0-9][0-9]-*.sh' |
    sort
)

if (( ${#MODULES[@]} == 0 ))
then

    echo
    echo "ERROR: No modules found."
    echo

    exit 1

fi

echo "Modules to be included:"
echo

printf '  %s\n' "${MODULES[@]}"

echo

cat "${MODULES[@]}" > "$BIN_FILE"

chmod +x "$BIN_FILE"

echo "Validating syntax..."

bash -n "$BIN_FILE"

echo "Syntax OK."

# =====================================================
# COMPLETIONS
# =====================================================

cp \
    "$SCRIPT_DIR/completion.bash" \
    "$BASH_COMPLETION_DIR/pacman-zta"

cp \
    "$SCRIPT_DIR/completion.zsh" \
    "$ZSH_COMPLETION_DIR/_pacman-zta"

# =====================================================
# PATH
# =====================================================

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]
then

    echo
    echo "Add this to your shell:"
    echo
    echo 'export PATH="$HOME/.local/bin:$PATH"'
    echo

fi

# =====================================================
# BASHRC
# =====================================================

if [[ -f "$HOME/.bashrc" ]]
then

    if ! grep -q \
        "bash-completion/completions/pacman-zta" \
        "$HOME/.bashrc"
    then

cat >> "$HOME/.bashrc" <<'EOF'

# pacman-zta completion
if [ -f ~/.local/share/bash-completion/completions/pacman-zta ]
then
    source ~/.local/share/bash-completion/completions/pacman-zta
fi

EOF

    fi

fi

# =====================================================
# ZSHRC
# =====================================================

if [[ -f "$HOME/.zshrc" ]]
then

    if ! grep -q \
        "pacman-zta completion" \
        "$HOME/.zshrc"
    then

cat >> "$HOME/.zshrc" <<'EOF'

# pacman-zta completion

if [[ -d ~/.local/share/zsh/site-functions ]]
then
    fpath=(~/.local/share/zsh/site-functions $fpath)
fi

autoload -Uz compinit
compinit

EOF

    fi

fi

# =====================================================
# DONE
# =====================================================

echo
echo "pacman-zta installed successfully."
echo
echo "Restart your shell or run:"
echo
echo "source ~/.bashrc"
echo "source ~/.zshrc"
echo
