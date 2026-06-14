# =====================================================
# 11-update.sh
# =====================================================

# =====================================================
# LIST MANAGED PACKAGES
# =====================================================

list_managed_packages() {

    find "$STATE_DIR" \
        -type f \
        -name "*.json" |
        sed 's|.*/||' |
        sed 's/.json$//'

}

# =====================================================
# PACKAGE NEEDS UPDATE
# =====================================================

package_has_update() {

    local PKG="$1"

    aur_clone "$PKG" || return 1

    cd "$CACHE_DIR/$PKG" || return 1

    local OLD_COMMIT
    local NEW_COMMIT

    OLD_COMMIT=$(state_get_commit "$PKG")
    NEW_COMMIT=$(aur_get_commit)

    [[ "$OLD_COMMIT" != "$NEW_COMMIT" ]]

}

# =====================================================
# SHOW UPDATE DIFF
# =====================================================

show_update_diff() {

    local PKG="$1"

    cd "$CACHE_DIR/$PKG" || return 1

    local OLD_COMMIT
    local NEW_COMMIT

    OLD_COMMIT=$(state_get_commit "$PKG")
    NEW_COMMIT=$(aur_get_commit)

    echo
    echo "================================="
    echo "$PKG"
    echo "================================="
    echo

    echo "Old commit:"
    echo "$OLD_COMMIT"
    echo

    echo "New commit:"
    echo "$NEW_COMMIT"
    echo

    show_diff "$OLD_COMMIT" "$NEW_COMMIT"

}

# =====================================================
# UPDATE SINGLE PACKAGE
# =====================================================

update_package() {

    local PKG="$1"

    log_info "Checking updates for $PKG"

    package_has_update "$PKG" || {

        log_info "$PKG already up to date"

        return 0

    }

    show_update_diff "$PKG"

    log_warn "$PKG has changed"

    install_from_aur "$PKG"

}

# =====================================================
# UPDATE MANAGED PACKAGES
# =====================================================

update_aur_packages() {

    local PKG

    for PKG in $(list_managed_packages)
    do

        update_package "$PKG"

    done

}

# =====================================================
# UPDATE OFFICIAL REPOSITORIES
# =====================================================

update_repo_packages() {

    log_info "Updating official repositories"

    sudo pacman -Syu

}

# =====================================================
# COMPLETE UPDATE
# =====================================================

update_system() {

    update_repo_packages || return 1

    update_aur_packages || return 1

}

# =====================================================
# CHECK OUTDATED MANAGED PACKAGES
# =====================================================

list_outdated_aur_packages() {

    local PKG

    for PKG in $(list_managed_packages)
    do

        if package_has_update "$PKG"
        then

            echo "$PKG"

        fi

    done

}

# =====================================================
# SHOW UPDATE STATUS
# =====================================================

show_update_status() {

    local PKG

    echo
    echo "Managed packages:"
    echo

    for PKG in $(list_managed_packages)
    do

        if package_has_update "$PKG"
        then

            echo "↑ $PKG"

        else

            echo "✓ $PKG"

        fi

    done

    echo

}

# =====================================================
# VERIFY PACKAGE CONSISTENCY
# =====================================================

verify_managed_packages() {

    local PKG

    for PKG in $(list_managed_packages)
    do

        pacman -Q "$PKG" >/dev/null 2>&1 || {

            log_warn "$PKG is no longer installed"

        }

    done

}
