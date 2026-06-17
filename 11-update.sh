# =====================================================
# 11-update.sh
# =====================================================

# =====================================================
# LIST MANAGED PACKAGES
# =====================================================

list_managed_packages() {

    command find \
        "$STATE_DIR" \
        -type f \
        -name "*.json" |
    command sed 's|.*/||' |
    command sed 's/.json$//'

}

# =====================================================
# PACKAGE NEEDS UPDATE
# =====================================================

package_has_update() {

    local OLD_COMMIT
    local NEW_COMMIT

    safe_git_clone || return 1

    OLD_COMMIT="$(state_get_commit "$CURRENT_PACKAGE")"

    NEW_COMMIT="$(
        command git \
            -C "$(get_package_dir)" \
            rev-parse HEAD
    )"

    [[ "$OLD_COMMIT" != "$NEW_COMMIT" ]]

}

# =====================================================
# SHOW UPDATE DIFF
# =====================================================

show_update_diff() {

    local OLD_COMMIT
    local NEW_COMMIT

    OLD_COMMIT="$(state_get_commit "$CURRENT_PACKAGE")"

    NEW_COMMIT="$(
        command git \
            -C "$(get_package_dir)" \
            rev-parse HEAD
    )"

    echo
    echo "================================="
    echo "$CURRENT_PACKAGE"
    echo "================================="
    echo

    echo "Old commit:"
    echo "$OLD_COMMIT"
    echo

    echo "New commit:"
    echo "$NEW_COMMIT"
    echo

    show_diff \
        "$OLD_COMMIT" \
        "$NEW_COMMIT"

}

# =====================================================
# UPDATE SINGLE PACKAGE
# =====================================================

update_package() {

    CURRENT_PACKAGE="$1"

    log_info \
        "Checking updates for $CURRENT_PACKAGE"

    if ! package_has_update
    then

        log_info \
            "$CURRENT_PACKAGE already up to date"

        cleanup_temp_workspace

        return 0

    fi

    show_update_diff

    log_warn \
        "$CURRENT_PACKAGE has changed"

    install_package \
        "$CURRENT_PACKAGE"

    cleanup_temp_workspace

}

# =====================================================
# UPDATE MANAGED PACKAGES
# =====================================================

update_aur_packages() {

    local PKG

    while read -r PKG
    do

        [[ -z "$PKG" ]] && continue

        update_package "$PKG"

    done < <(list_managed_packages)

}

# =====================================================
# UPDATE OFFICIAL REPOSITORIES
# =====================================================

update_repo_packages() {

    log_info \
        "Updating official repositories"

    sudo pacman -Syu

}

# =====================================================
# COMPLETE UPDATE
# =====================================================

update_system() {

    update_repo_packages ||
        return 1

    update_aur_packages ||
        return 1

}

# =====================================================
# CHECK OUTDATED MANAGED PACKAGES
# =====================================================

list_outdated_aur_packages() {

    local PKG

    while read -r PKG
    do

        [[ -z "$PKG" ]] && continue

        CURRENT_PACKAGE="$PKG"

        if package_has_update
        then

            echo "$PKG"
        fi

        cleanup_temp_workspace

    done < <(list_managed_packages)

}

# =====================================================
# SHOW UPDATE STATUS
# =====================================================

show_update_status() {

    local PKG

    echo
    echo "Managed packages:"
    echo

    while read -r PKG
    do

        [[ -z "$PKG" ]] && continue

        CURRENT_PACKAGE="$PKG"

        if package_has_update
        then

            echo "↑ $PKG"
        else
            echo "✓ $PKG"
        fi

        cleanup_temp_workspace

    done < <(list_managed_packages)

    echo

}

# =====================================================
# VERIFY PACKAGE CONSISTENCY
# =====================================================

verify_managed_packages() {

    local PKG

    while read -r PKG
    do

        [[ -z "$PKG" ]] && continue

        command pacman \
            -Q "$PKG" \
            >/dev/null 2>&1 || {

            log_warn \
                "$PKG is no longer installed"

        }

    done < <(list_managed_packages)

}
