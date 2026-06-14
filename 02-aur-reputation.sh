# =====================================================
# 02-aur-reputation.sh
# =====================================================

# =====================================================
# PACKAGE AGE CHECK
# =====================================================

check_package_age() {

    local AGE

    AGE=$(get_package_age_days)

    printf "%-25s %s days\n" "Package age:" "$AGE"

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

    local PKG="$1"
    local VOTES

    VOTES=$(
        curl -fsSL \
        "https://aur.archlinux.org/rpc/?v=5&type=info&arg[]=${PKG}" |
        jq -r '.results[0].NumVotes'
    )

    printf "%-25s %s\n" "Votes:" "$VOTES"

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

    local PKG="$1"
    local POPULARITY

    POPULARITY=$(
        curl -fsSL \
        "https://aur.archlinux.org/rpc/?v=5&type=info&arg[]=${PKG}" |
        jq -r '.results[0].Popularity'
    )

    printf "%-25s %s\n" "Popularity:" "$POPULARITY"

    awk -v p="$POPULARITY" -v m="$MIN_POPULARITY" \
        'BEGIN { exit !(p < m) }'

    if [[ $? -eq 0 ]]
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

    local COUNT

    COUNT=$(get_commit_count)

    printf "%-25s %s\n" "Commit count:" "$COUNT"

}

# =====================================================
# LAST COMMIT DATE
# =====================================================

check_last_commit_date() {

    local DATE

    DATE=$(get_last_commit_date)

    printf "%-25s %s\n" "Last commit date:" "$DATE"

}

# =====================================================
# LAST COMMIT HASH
# =====================================================

check_last_commit_hash() {

    local HASH

    HASH=$(get_last_commit_hash)

    printf "%-25s %s\n" "Last commit hash:" "$HASH"

}

# =====================================================
# REPUTATION
# =====================================================

run_reputation_checks() {

    local PKG="$1"

    echo "======================================"
    echo "REPUTATION"
    echo "======================================"

    check_package_age

    check_package_votes "$PKG"

    check_package_popularity "$PKG"

    check_commit_count

    check_last_commit_date

    check_last_commit_hash

    echo

}
