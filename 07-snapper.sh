# =====================================================
# 07-snapper.sh
# =====================================================

# =====================================================
# SNAPSHOT AVAILABLE?
# =====================================================

has_snapper() {

    command -v snapper >/dev/null 2>&1

}

# =====================================================
# CREATE SNAPSHOT
# =====================================================

create_snapshot() {

    local DESCRIPTION="$1"

    has_snapper || return 1

    log_info "Creating snapper snapshot..."

    snapper create \
        --type pre \
        --description "$DESCRIPTION" \
        >/dev/null

}

# =====================================================
# GET LAST SNAPSHOT ID
# =====================================================

get_last_snapshot_id() {

    has_snapper || return

    snapper list |
        awk 'END{print $1}'

}

# =====================================================
# SAVE SNAPSHOT ID
# =====================================================

save_snapshot_id() {

    local PKG="$1"
    local SNAPSHOT_ID="$2"

    local FILE

    FILE="$(get_approved_state_file "$PKG")"

    [[ -f "$FILE" ]] || return

    echo "SNAPSHOT_ID=\"$SNAPSHOT_ID\"" >> "$FILE"

}

# =====================================================
# SHOW SNAPSHOT ID
# =====================================================

show_snapshot_id() {

    [[ -n "$SNAPSHOT_ID" ]] || return

    printf "%-25s %s\n" \
        "Snapshot ID:" \
        "$SNAPSHOT_ID"

}
