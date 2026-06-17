# =====================================================
# INSTALL PACKAGE
# =====================================================

install_package() {

    local LEVEL
    local ANSWER

    CURRENT_PACKAGE="$1"

    audit_package "$CURRENT_PACKAGE" || true

    LEVEL="$(get_score_level)"

    echo

    #
    # HARD FAILURE ALWAYS BLOCKS
    #

    if (( HARD_FAILURE ))
    then

        echo
        echo "Package failed security requirements."
        echo

        printf ' - %s\n' "${FAILURE_MESSAGES[@]}"

        echo

        log_security \
            "Installation blocked."

        return 1

    fi

    #
    # REVIEW MODE
    #

    if (( FAILURES > 0 ))
    then

        case "$LEVEL" in

            EXCELLENT|GOOD)

                echo
                echo "Package has warnings:"
                echo

                printf ' - %s\n' "${FAILURE_MESSAGES[@]}"

                echo

                read -rp \
                    "Continue installation? [y/N] " \
                    ANSWER

                echo

                [[ "$ANSWER" =~ ^[Yy]$ ]] || {

                    log_warn \
                        "Installation cancelled by user."

                    return 1

                }

                ;;

            WARNING|CRITICAL)

                echo
                echo "Package failed security requirements."
                echo

                printf ' - %s\n' "${FAILURE_MESSAGES[@]}"

                echo

                log_security \
                    "Installation blocked."

                return 1

                ;;

        esac

    fi

    #
    # BUILD
    #

    echo

    log_info \
        "Building package..."

    build_package ||
        return 1

    #
    # SNAPSHOT
    #

    SNAPSHOT_ID=""

    if has_snapper
    then

        echo

        log_info \
            "Creating pre-install snapshot..."

        create_snapshot \
            "PRE-AUR: $CURRENT_PACKAGE"

        SNAPSHOT_ID="$(
            get_last_snapshot_id
        )"

        log_info \
            "Snapshot created: $SNAPSHOT_ID"

    fi

    #
    # INSTALL
    #

    echo

    log_info \
        "Installing package..."

    install_built_package ||
        return 1

    register_managed_package \
        "$CURRENT_PACKAGE"

    #
    # SAVE APPROVED STATE
    #

    CURRENT_AUDIT_TIME="$(
        get_current_audit_time
    )"

    CURRENT_HASH="$(
        get_last_commit_hash
    )"

    CURRENT_COMMITS="$(
        get_commit_count
    )"

    CURRENT_MAINTAINER="$(
        get_current_maintainer
    )"

    save_approved_state \
        "$CURRENT_PACKAGE"

    echo

    log_success \
        "$CURRENT_PACKAGE installed successfully."

    if [[ -n "${SNAPSHOT_ID:-}" ]]
    then

        echo

        printf "%-25s %s\n" \
            "Snapshot ID:" \
            "$SNAPSHOT_ID"

    fi

}

# =====================================================
# INSTALL
# =====================================================

install() {

    [[ $# -eq 0 ]] && {

        log_error \
            "No package specified"

        return 1

    }

    local PKG

    for PKG in "$@"
    do

        install_package "$PKG"
    done

}
