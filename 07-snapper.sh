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

    if ! command snapper create \
        --type pre \
        --description "$DESCRIPTION" \
        >/dev/null
    then

        log_error "Unable to create snapshot"

        return 1

    fi

}

# =====================================================
# GET LAST SNAPSHOT ID
# =====================================================

get_last_snapshot_id() {

    has_snapper || return 1

    command snapper list |
        awk '
            NF > 0 && $1 ~ /^[0-9]+$/ {
                ID=$1
            }
            END {
                print ID
            }
        '

}

# =====================================================
# SAVE SNAPSHOT ID
# =====================================================

save_snapshot_id() {

    local PKG="$1"
    local SNAPSHOT_ID="$2"
    local FILE

    [[ -n "$SNAPSHOT_ID" ]] || return 1

    FILE="$(get_approved_state_file "$PKG")"

    [[ -f "$FILE" ]] || return 1

    command sed \
        -i \
        '/^SNAPSHOT_ID=/d' \
        "$FILE"

    echo "SNAPSHOT_ID=\"$SNAPSHOT_ID\"" \
        >> "$FILE"

}

# =====================================================
# SHOW SNAPSHOT ID
# =====================================================

show_snapshot_id() {

    [[ -n "${SNAPSHOT_ID:-}" ]] || return

    printf "%-25s %s\n" \
        "Snapshot ID:" \
        "$SNAPSHOT_ID"

}
