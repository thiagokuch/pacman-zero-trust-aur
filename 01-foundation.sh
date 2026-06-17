#!/usr/bin/env bash

set -eEuo pipefail

PATH=/usr/bin:/bin
export PATH

IFS=$' \t\n'

shopt -s failglob

# =====================================================
# DIRECTORIES
# =====================================================

CACHE_DIR="$HOME/.cache/pacman-zta"
STATE_DIR="$HOME/.local/share/pacman-zta/state"
BUILD_CACHE_DIR="$HOME/.cache/pacman-zta/build"
TMP_ROOT="/tmp/pacman-zta"

mkdir -p "$CACHE_DIR"
mkdir -p "$STATE_DIR"
mkdir -p "$BUILD_CACHE_DIR"
mkdir -p "$TMP_ROOT"

CACHE_DIR="$(command realpath "$CACHE_DIR")"
STATE_DIR="$(command realpath "$STATE_DIR")"
BUILD_CACHE_DIR="$(command realpath "$BUILD_CACHE_DIR")"
TMP_ROOT="$(command realpath "$TMP_ROOT")"

readonly CACHE_DIR
readonly STATE_DIR
readonly BUILD_CACHE_DIR
readonly TMP_ROOT

declare TMP_DIR=""
declare CURRENT_PACKAGE=""

# =====================================================
# PANIC
# =====================================================

panic() {

    log_security "PANIC: $1"

    exit 1

}

# =====================================================
# VERIFY PATHS
# =====================================================

verify_paths() {

    [[ -d "$CACHE_DIR" ]] || panic "Invalid CACHE_DIR"
    [[ -d "$STATE_DIR" ]] || panic "Invalid STATE_DIR"
    [[ -d "$BUILD_CACHE_DIR" ]] || panic "Invalid BUILD_CACHE_DIR"
    [[ -d "$TMP_ROOT" ]] || panic "Invalid TMP_ROOT"

    [[ ! -L "$CACHE_DIR" ]] || panic "CACHE_DIR is symlink"
    [[ ! -L "$STATE_DIR" ]] || panic "STATE_DIR is symlink"
    [[ ! -L "$BUILD_CACHE_DIR" ]] || panic "BUILD_CACHE_DIR is symlink"
    [[ ! -L "$TMP_ROOT" ]] || panic "TMP_ROOT is symlink"

}

# =====================================================
# PACKAGE DIRECTORY
# =====================================================

get_package_dir() {

    echo "$TMP_DIR/$CURRENT_PACKAGE"

}

# =====================================================
# SAFE DELETE CACHE
# =====================================================

safe_delete_cache() {

    command find \
        "$CACHE_DIR" \
        -mindepth 1 \
        -xdev \
        ! -type l \
        -exec unlink {} \;

}

# =====================================================
# SAFE DELETE STATE
# =====================================================

safe_delete_state() {

    command find \
        "$STATE_DIR" \
        -type f \
        -delete

}

# =====================================================
# SAFE DELETE BUILD CACHE
# =====================================================

safe_delete_build_cache() {

    command find \
        "$BUILD_CACHE_DIR" \
        -mindepth 1 \
        -xdev \
        ! -type l \
        -delete

}

# =====================================================
# CREATE TEMP WORKSPACE
# =====================================================

create_temp_workspace() {

    [[ -z "${TMP_DIR:-}" ]] \
        || panic "Workspace already exists"

    TMP_DIR="$(command mktemp -d "$TMP_ROOT/tmp.XXXXXX")"

    TMP_DIR="$(command realpath "$TMP_DIR")"

    [[ "$TMP_DIR" == "$TMP_ROOT/"* ]] \
        || panic "TMP escaped TMP_ROOT"

}

# =====================================================
# CLEANUP TEMP WORKSPACE
# =====================================================

cleanup_temp_workspace() {

    [[ -z "${TMP_DIR:-}" ]] && return
    [[ ! -d "$TMP_DIR" ]] && {

        TMP_DIR=""

        return

    }

    [[ ! -L "$TMP_DIR" ]] \
        || panic "TMP_DIR is symlink"

    command find \
        "$TMP_DIR" \
        -mindepth 1 \
        -xdev \
        ! -type l \
        -delete

    rmdir "$TMP_DIR" 2>/dev/null || true

    TMP_DIR=""

}

# =====================================================
# SAFE GIT CLONE
# =====================================================

safe_git_clone() {

    create_temp_workspace

    if ! command git clone \
        "https://aur.archlinux.org/${CURRENT_PACKAGE}.git" \
        "$(get_package_dir)" \
        >/dev/null \
        2>"$CACHE_DIR/clone.log"
    then

        add_hard_failure \
            "Unable to clone package repository"

        cleanup_temp_workspace

        return 1

    fi

}

trap -- cleanup_temp_workspace EXIT

verify_paths
