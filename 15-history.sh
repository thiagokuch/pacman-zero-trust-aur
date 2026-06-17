# =====================================================
# 15-history.sh
# =====================================================

# =====================================================
# STATE FILES
# =====================================================

get_last_state_file() {

    echo "$STATE_DIR/${CURRENT_PACKAGE}.last.state"

}

get_approved_state_file() {

    echo "$STATE_DIR/${CURRENT_PACKAGE}.approved.state"

}

# =====================================================
# STATE VALUE
# =====================================================

get_state_value() {

    local FILE="$1"
    local KEY="$2"

    [[ -f "$FILE" ]] || return

    command grep \
        "^${KEY}=" \
        "$FILE" |
    head -n1 |
    cut -d= -f2- |
    tr -d '"'

}

# =====================================================
# LOAD APPROVED STATE
# =====================================================

load_package_state() {

    local STATE_FILE

    STATE_FILE="$(get_approved_state_file)"

    LAST_AUDIT="never"
    LAST_HASH=""
    LAST_COMMITS=0
    LAST_MAINTAINER=""
    LAST_SCORE=100
    SNAPSHOT_ID=""

    [[ -f "$STATE_FILE" ]] || return 0

    LAST_AUDIT="$(
        get_state_value \
            "$STATE_FILE" \
            LAST_AUDIT
    )"

    LAST_HASH="$(
        get_state_value \
            "$STATE_FILE" \
            LAST_HASH
    )"

    LAST_COMMITS="$(
        get_state_value \
            "$STATE_FILE" \
            LAST_COMMITS
    )"

    LAST_MAINTAINER="$(
        get_state_value \
            "$STATE_FILE" \
            LAST_MAINTAINER
    )"

    LAST_SCORE="$(
        get_state_value \
            "$STATE_FILE" \
            LAST_SCORE
    )"

    SNAPSHOT_ID="$(
        get_state_value \
            "$STATE_FILE" \
            SNAPSHOT_ID
    )"

}

# =====================================================
# SAVE LAST AUDIT
# =====================================================

save_last_state() {

    local STATE_FILE

    STATE_FILE="$(get_last_state_file)"

    cat > "$STATE_FILE" <<EOF
LAST_AUDIT="$CURRENT_AUDIT_TIME"
LAST_HASH="$CURRENT_HASH"
LAST_COMMITS="$CURRENT_COMMITS"
LAST_MAINTAINER="$CURRENT_MAINTAINER"
LAST_SCORE="$CURRENT_SCORE"
EOF

}

# =====================================================
# SAVE APPROVED STATE
# =====================================================

save_approved_state() {

    local STATE_FILE

    STATE_FILE="$(get_approved_state_file)"

    cat > "$STATE_FILE" <<EOF
LAST_AUDIT="$CURRENT_AUDIT_TIME"
LAST_HASH="$CURRENT_HASH"
LAST_COMMITS="$CURRENT_COMMITS"
LAST_MAINTAINER="$CURRENT_MAINTAINER"
LAST_SCORE="$CURRENT_SCORE"
SNAPSHOT_ID="$SNAPSHOT_ID"
EOF

}

# =====================================================
# CURRENT TIME
# =====================================================

get_current_audit_time() {

    date "+%Y-%m-%d %H:%M:%S"

}

# =====================================================
# SHOW LAST AUDIT
# =====================================================

show_last_audit() {

    printf "%-25s %s\n" \
        "Last approved audit:" \
        "$LAST_AUDIT"

}

# =====================================================
# SHOW PREVIOUS SCORE
# =====================================================

show_previous_score() {

    printf "%-25s %s\n" \
        "Previous score:" \
        "$LAST_SCORE"

}

# =====================================================
# SHOW SNAPSHOT
# =====================================================

show_snapshot_id() {

    [[ -n "${SNAPSHOT_ID:-}" ]] || return

    printf "%-25s %s\n" \
        "Snapshot ID:" \
        "$SNAPSHOT_ID"

}
