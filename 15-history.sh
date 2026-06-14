# =====================================================
# 15-history.sh
# =====================================================

# =====================================================
# STATE FILES
# =====================================================

get_last_state_file() {

    local PKG="$1"

    echo "$STATE_DIR/${PKG}.last.state"

}

get_approved_state_file() {

    local PKG="$1"

    echo "$STATE_DIR/${PKG}.approved.state"

}

# =====================================================
# LOAD APPROVED STATE
# =====================================================

load_package_state() {

    local PKG="$1"
    local STATE_FILE

    STATE_FILE="$(get_approved_state_file "$PKG")"

    LAST_AUDIT="never"
    LAST_HASH=""
    LAST_COMMITS=0
    LAST_MAINTAINER=""
    LAST_SCORE=100
    SNAPSHOT_ID=""

    [[ -f "$STATE_FILE" ]] || return 0

    # shellcheck disable=SC1090
    source "$STATE_FILE"

}

# =====================================================
# SAVE LAST AUDIT
# =====================================================

save_last_state() {

    local PKG="$1"
    local STATE_FILE

    STATE_FILE="$(get_last_state_file "$PKG")"

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

    local PKG="$1"
    local STATE_FILE

    STATE_FILE="$(get_approved_state_file "$PKG")"

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

    [[ -z "$SNAPSHOT_ID" ]] && return

    printf "%-25s %s\n" \
        "Snapshot ID:" \
        "$SNAPSHOT_ID"

}
