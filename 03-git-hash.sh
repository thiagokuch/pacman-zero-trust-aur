# =====================================================
# 03-git-hash.sh
# =====================================================

# =====================================================
# PACKAGE AGE
# =====================================================

get_package_age_days() {

    local FIRST_COMMIT
    local NOW

    FIRST_COMMIT=$(
        command git \
            -C "$(get_package_dir)" \
            log \
            --reverse \
            --format='%ct' |
            head -n1
    )

    NOW="$(date +%s)"

    echo $(( (NOW - FIRST_COMMIT) / 86400 ))

}

# =====================================================
# COMMIT COUNT
# =====================================================

get_commit_count() {

    command git \
        -C "$(get_package_dir)" \
        rev-list \
        --count \
        HEAD

}

# =====================================================
# LAST COMMIT HASH
# =====================================================

get_last_commit_hash() {

    command git \
        -C "$(get_package_dir)" \
        rev-parse \
        HEAD

}

# =====================================================
# LAST COMMIT DATE
# =====================================================

get_last_commit_date() {

    command git \
        -C "$(get_package_dir)" \
        log \
        -1 \
        --format='%cs'

}

# =====================================================
# CURRENT MAINTAINER
# =====================================================

get_current_maintainer() {

    command git \
        -C "$(get_package_dir)" \
        log \
        -1 \
        --format='%an'

}
