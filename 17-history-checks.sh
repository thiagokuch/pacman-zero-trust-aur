# =====================================================
# 17-history-checks.sh
# =====================================================

declare HASH_CHANGED="no"
declare MAINTAINER_CHANGED="no"
declare COMMIT_GROWTH="+0"

# =====================================================
# CURRENT MAINTAINER
# =====================================================

get_current_maintainer() {

    command grep \
        '^# Maintainer:' \
        "$(get_pkgbuild_file)" |
    head -n1 |
    sed 's/^# Maintainer:[[:space:]]*//'

}

# =====================================================
# HASH CHANGE
# =====================================================

check_hash_change() {

    CURRENT_HASH="$(get_last_commit_hash)"

    HASH_CHANGED="no"

    [[ -n "${LAST_HASH:-}" ]] || return

    if [[ "$CURRENT_HASH" != "$LAST_HASH" ]]
    then

        HASH_CHANGED="yes"

        log_warn \
            "Commit hash changed since last audit"

        add_failure \
            "Commit hash changed since last audit"

        penalty_hash_change

    fi

}

# =====================================================
# MAINTAINER CHANGE
# =====================================================

check_maintainer_change() {

    CURRENT_MAINTAINER="$(
        get_current_maintainer
    )"

    MAINTAINER_CHANGED="no"

    [[ -n "${LAST_MAINTAINER:-}" ]] || return

    if [[ "$CURRENT_MAINTAINER" != "$LAST_MAINTAINER" ]]
    then

        MAINTAINER_CHANGED="yes"

        log_security \
            "Maintainer changed since last audit"

        add_failure \
            "Maintainer changed since last audit"

        penalty_maintainer_change

    fi

}

# =====================================================
# COMMIT GROWTH
# =====================================================

check_commit_growth() {

    local DELTA

    CURRENT_COMMITS="$(
        get_commit_count
    )"

    COMMIT_GROWTH="+0"

    (( LAST_COMMITS == 0 )) &&
        return

    DELTA=$(
        (
            CURRENT_COMMITS -
            LAST_COMMITS
        )
    )

    COMMIT_GROWTH="+${DELTA}"

    if (( DELTA > 20 ))
    then

        log_warn \
            "Unusually large commit increase (+${DELTA})"

        add_failure \
            "Unusually large commit increase (+${DELTA})"

        penalty_commit_growth

    fi

}

# =====================================================
# SHOW HISTORY
# =====================================================

show_history() {

    echo
    echo "======================================"
    echo "HISTORY"
    echo "======================================"

    show_last_audit

    show_previous_score

    printf "%-25s %s\n" \
        "Current score:" \
        "$CURRENT_SCORE"

    printf "%-25s %s\n" \
        "Hash changed:" \
        "$HASH_CHANGED"

    printf "%-25s %s\n" \
        "Maintainer changed:" \
        "$MAINTAINER_CHANGED"

    printf "%-25s %s commits\n" \
        "Commit growth:" \
        "$COMMIT_GROWTH"

    echo

}

# =====================================================
# RUN HISTORY CHECKS
# =====================================================

run_history_checks() {

    load_package_state

    check_hash_change

    check_maintainer_change

    check_commit_growth

    show_history

}
