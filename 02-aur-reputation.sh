# =====================================================
# 02-aur-reputation.sh
# =====================================================

declare AUR_JSON=""

# =====================================================
# GET AUR INFO
# =====================================================

get_aur_info() {

    AUR_JSON=$(
        command curl \
            -fsSL \
            --connect-timeout 10 \
            --max-time 30 \
            "https://aur.archlinux.org/rpc/?v=5&type=info&arg[]=${CURRENT_PACKAGE}"
    ) || {

        add_hard_failure \
            "Unable to query AUR API"

        return 1

    }

}

# =====================================================
# PACKAGE AGE CHECK
# =====================================================

check_package_age() {

    local AGE

    AGE="$(get_package_age_days)"

    printf "%-25s %s days\n" \
        "Package age:" \
        "$AGE"

    if (( AGE < MIN_AGE_DAYS ))
    then

        log_security \
            "Package age below threshold (${AGE} < ${MIN_AGE_DAYS})"

        add_failure \
            "Package age below threshold (${AGE} < ${MIN_AGE_DAYS})"

        penalty_package_age

        return 1

    fi

}

# =====================================================
# PACKAGE VOTES CHECK
# =====================================================

check_package_votes() {

    local VOTES

    VOTES=$(
        command jq \
            -r '.results[0].NumVotes' \
            <<< "$AUR_JSON"
    )

    printf "%-25s %s\n" \
        "Votes:" \
        "$VOTES"

    if (( VOTES < MIN_VOTES ))
    then

        log_security \
            "Votes below threshold (${VOTES} < ${MIN_VOTES})"

        add_failure \
            "Votes below threshold (${VOTES} < ${MIN_VOTES})"

        penalty_votes

        return 1

    fi

}

# =====================================================
# PACKAGE POPULARITY CHECK
# =====================================================

check_package_popularity() {

    local POPULARITY

    POPULARITY=$(
        command jq \
            -r '.results[0].Popularity' \
            <<< "$AUR_JSON"
    )

    printf "%-25s %s\n" \
        "Popularity:" \
        "$POPULARITY"

    if awk \
        -v p="$POPULARITY" \
        -v m="$MIN_POPULARITY" \
        'BEGIN { exit !(p < m) }'
    then

        log_security \
            "Popularity below threshold (${POPULARITY} < ${MIN_POPULARITY})"

        add_failure \
            "Popularity below threshold (${POPULARITY} < ${MIN_POPULARITY})"

        penalty_popularity

        return 1

    fi

}

# =====================================================
# COMMIT COUNT
# =====================================================

check_commit_count() {

    printf "%-25s %s\n" \
        "Commit count:" \
        "$(get_commit_count)"

}

# =====================================================
# LAST COMMIT DATE
# =====================================================

check_last_commit_date() {

    printf "%-25s %s\n" \
        "Last commit date:" \
        "$(get_last_commit_date)"

}

# =====================================================
# LAST COMMIT HASH
# =====================================================

check_last_commit_hash() {

    printf "%-25s %s\n" \
        "Last commit hash:" \
        "$(get_last_commit_hash)"

}

# =====================================================
# REPUTATION
# =====================================================

run_reputation_checks() {

    echo "======================================"
    echo "REPUTATION"
    echo "======================================"

    get_aur_info || return 1

    check_package_age
    check_package_votes
    check_package_popularity
    check_commit_count
    check_last_commit_date
    check_last_commit_hash

    echo

}
