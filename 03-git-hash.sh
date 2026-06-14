# =====================================================
# 03-git-hash.sh
# =====================================================

# =====================================================
# CLONE PACKAGE
# =====================================================

aur_clone() {

    local PKG="$1"
    local TMP_DIR="$2"

    if ! git clone \
        "https://aur.archlinux.org/${PKG}.git" \
        "$TMP_DIR/$PKG" \
        >/dev/null 2>/tmp/pacman-zta-clone.log
    then

        log_error "Unable to clone $PKG"

        echo
        echo "Git output:"
        cat /tmp/pacman-zta-clone.log
        echo

        add_hard_failure \
            "Unable to clone package repository"

        return 1

    fi

}

# =====================================================
# ENTER PACKAGE DIRECTORY
# =====================================================

enter_package_dir() {

    local PKG="$1"
    local TMP_DIR="$2"

    cd "$TMP_DIR/$PKG" || {

        log_error "Unable to enter package directory"

        return 1

    }

}

# =====================================================
# PACKAGE AGE
# =====================================================

get_package_age_days() {

    local FIRST_COMMIT
    local NOW

    FIRST_COMMIT=$(
        git log \
            --reverse \
            --format='%ct' |
            head -n1
    )

    NOW=$(date +%s)

    echo $(( (NOW - FIRST_COMMIT) / 86400 ))

}

# =====================================================
# COMMIT COUNT
# =====================================================

get_commit_count() {

    git rev-list --count HEAD

}

# =====================================================
# LAST COMMIT HASH
# =====================================================

get_last_commit_hash() {

    git rev-parse HEAD

}

# =====================================================
# LAST COMMIT DATE
# =====================================================

get_last_commit_date() {

    git log -1 --format='%cs'

}
