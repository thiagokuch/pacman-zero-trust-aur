# =====================================================
# RESET CACHE
# =====================================================

reset_cache() {

    log_warn \
        "Resetting cache"

    safe_delete_cache

    log_success \
        "Cache reset"

}

# =====================================================
# RESET STATES
# =====================================================

reset_states() {

    log_warn \
        "Resetting state database"

    safe_delete_state

    log_success \
        "State database reset"

}

# =====================================================
# CLEAN CACHE
# =====================================================

clean_cache() {

    log_info \
        "Cleaning pacman cache"

    if command -v paccache >/dev/null 2>&1
    then

        #
        # Remove uninstalled packages
        #

        sudo paccache -ruk0

        #
        # Keep last three versions
        #

        sudo paccache -rk3

    else

        sudo pacman -Sc

    fi

    log_success \
        "Cache cleaned"

}

# =====================================================
# STATUS
# =====================================================

show_status() {

    local PKG="$1"
    local STATE_FILE

    STATE_FILE="$STATE_DIR/${PKG}.approved.state"

    [[ -f "$STATE_FILE" ]] || {

        log_warn \
            "No state found for $PKG"

        return 1

    }

    print_section "STATUS"

    command grep \
        -E \
        'timestamp|score|maintainer|commit_hash|snapshot_id' \
        "$STATE_FILE"

}
