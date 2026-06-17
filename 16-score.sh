# =====================================================
# 16-score.sh
# =====================================================

declare CURRENT_SCORE=100
declare FAILURES=0
declare HARD_FAILURE=0
declare -a FAILURE_MESSAGES=()

# =====================================================
# RESET SCORE
# =====================================================

reset_score() {

    CURRENT_SCORE=100

    FAILURES=0

    HARD_FAILURE=0

    FAILURE_MESSAGES=()

}

# =====================================================
# REGISTER FAILURE
# =====================================================

add_failure() {

    local MESSAGE="$1"
    local FAILURE

    for FAILURE in "${FAILURE_MESSAGES[@]}"
    do

        [[ "$FAILURE" == "$MESSAGE" ]] && return

    done

    FAILURE_MESSAGES+=("$MESSAGE")

}

# =====================================================
# REGISTER HARD FAILURE
# =====================================================

add_hard_failure() {

    HARD_FAILURE=1

    add_failure "$1"

}

# =====================================================
# APPLY PENALTY
# =====================================================

score_penalty() {

    local POINTS="$1"

    (( CURRENT_SCORE -= POINTS ))

    (( CURRENT_SCORE < 0 )) &&
        CURRENT_SCORE=0

    (( FAILURES++ ))

}

# =====================================================
# CURRENT SCORE
# =====================================================

get_current_score() {

    echo "$CURRENT_SCORE"

}

# =====================================================
# SCORE LEVEL
# =====================================================

get_score_level() {

    if (( CURRENT_SCORE >= 90 ))
    then

        echo "EXCELLENT"

    elif (( CURRENT_SCORE >= 75 ))
    then

        echo "GOOD"

    elif (( CURRENT_SCORE >= 50 ))
    then

        echo "WARNING"

    else

        echo "CRITICAL"

    fi

}

# =====================================================
# INSTALL ALLOWED?
# =====================================================

install_allowed() {

    (( HARD_FAILURE )) &&
        return 1

    local LEVEL

    LEVEL="$(get_score_level)"

    [[ "$LEVEL" == "EXCELLENT" ||
       "$LEVEL" == "GOOD" ]]

}

# =====================================================
# SHOW FAILURES
# =====================================================

show_failures() {

    (( ${#FAILURE_MESSAGES[@]} == 0 )) &&
        return

    echo
    echo "Failures:"
    echo

    printf ' - %s\n' \
        "${FAILURE_MESSAGES[@]}"

}

# =====================================================
# SHOW SCORE
# =====================================================

show_score() {

    printf "%-25s %s/100\n" \
        "Security score:" \
        "$CURRENT_SCORE"

    printf "%-25s %s\n" \
        "Failures detected:" \
        "$FAILURES"

    printf "%-25s %s\n" \
        "Risk level:" \
        "$(get_score_level)"

    printf "%-25s %s\n" \
        "Hard failures:" \
        "$HARD_FAILURE"

    show_failures

}

# =====================================================
# PENALTIES
# =====================================================

penalty_package_age() { score_penalty 20; }

penalty_votes() { score_penalty 15; }

penalty_popularity() { score_penalty 15; }

penalty_shellcheck() { score_penalty 20; }

penalty_namcap() { score_penalty 10; }

penalty_hooks() { score_penalty 25; }

penalty_blacklist_pattern() { score_penalty 30; }

penalty_hash_change() { score_penalty 10; }

penalty_maintainer_change() { score_penalty 25; }

penalty_commit_growth() { score_penalty 15; }
