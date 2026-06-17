# =====================================================
# 12-status-cache.sh
# =====================================================

# =====================================================
# REMOVE PACKAGE
# =====================================================

remove_package() {

    local PKG="$1"

    log_info "Removing $PKG"

    sudo pacman -Rns "$PKG"

    if [[ $? -eq 0 ]]
    then

        rm -f "$STATE_DIR/$PKG.json"

        log_success "$PKG removed"

    else

        log_error "Failed to remove $PKG"

        return 1

    fi

}

# =====================================================
# SHOW PACKAGE STATUS
# =====================================================

show_package_status() {

    local PKG="$1"

    pkg_state_exists "$PKG" || {

        log_error "$PKG is not managed by pacman-zta"

        return 1

    }

    local SNAPSHOT
    local VERSION
    local MAINTAINER
    local COMMIT

    SNAPSHOT=$(state_get_snapshot "$PKG")
    VERSION=$(jq -r '.version' "$STATE_DIR/$PKG.json")
    MAINTAINER=$(state_get_maintainer "$PKG")
    COMMIT=$(state_get_commit "$PKG")

    echo
    echo "=================================="
    echo "$PKG"
    echo "=================================="
    echo
    echo "Version     : $VERSION"
    echo "Maintainer  : $MAINTAINER"
    echo "Snapshot    : $SNAPSHOT"
    echo "Commit      : $COMMIT"
    echo

}

# =====================================================
# LIST MANAGED PACKAGES
# =====================================================

show_all_managed_packages() {

    local PKG

    echo

    for PKG in $(list_managed_packages)
    do

        echo "$PKG"

    done

    echo

}

# =====================================================
# SHOW SNAPSHOT
# =====================================================

show_snapshot() {

    local PKG="$1"

    pkg_state_exists "$PKG" || return 1

    echo
    echo "Snapshot:"
    echo "$(state_get_snapshot "$PKG")"
    echo

}

# =====================================================
# CLEAN CACHE
# =====================================================

clean_cache() {
    log_message "INFO" "Starting system cache cleanup..."
    if command -v paccache &> /dev/null; then
        echo "Removing uninstalled packages from cache (keeping last 2 versions)..."
        sudo paccache -r
        echo "Removing all cached versions of uninstalled packages..."
        sudo paccache -rk0
        log_message "SUCCESS" "Package cache cleanup complete using paccache."
    else
        sudo pacman -Sc --noconfirm
        log_message "SUCCESS" "Package cache cleanup complete using pacman -Sc."
    fi
}


# =====================================================
# PURGE ORPHAN STATES
# =====================================================

purge_states() {

    local PKG

    for PKG in $(list_managed_packages)
    do

        if ! pacman -Q "$PKG" >/dev/null 2>&1
        then

            log_warn "Removing stale state for $PKG"

            rm -f "$STATE_DIR/$PKG.json"

        fi

    done

}

# =====================================================
# SHOW CACHE USAGE
# =====================================================

show_cache_usage() {

    echo

    du -sh "$CACHE_DIR"

    echo

}

# =====================================================
# SHOW STATE USAGE
# =====================================================

show_state_usage() {

    echo

    du -sh "$STATE_DIR"

    echo

}

# =====================================================
# COMPLETE STATUS
# =====================================================

show_status() {

    echo

    echo "Managed packages:"
    echo

    show_all_managed_packages

    echo "Cache size:"
    show_cache_usage

    echo "State size:"
    show_state_usage

}

# =====================================================
# RESET CACHE
# =====================================================

reset_cache() {

    log_warn "Resetting cache"

    rm -rf "$CACHE_DIR"

    mkdir -p "$CACHE_DIR"

}

# =====================================================
# RESET STATES
# =====================================================

reset_states() {

    log_warn "Resetting states"

    rm -rf "$STATE_DIR"

    mkdir -p "$STATE_DIR"

}

# =====================================================
# FULL CLEAN
# =====================================================

full_clean() {

    clean_cache

    purge_states

}
