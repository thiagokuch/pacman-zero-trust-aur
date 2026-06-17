# =====================================================
# 13-audit.sh
# =====================================================

# =====================================================
# AUDIT PACKAGE
# =====================================================

audit_package() {

    local LEVEL
    local RESULT

    CURRENT_PACKAGE="$1"

    reset_score

    echo
    echo "======================================"
    echo "AUDITING $CURRENT_PACKAGE"
    echo "======================================"
    echo

    safe_git_clone || return 1

    run_reputation_checks

    echo
    echo "======================================"
    echo "PKGBUILD"
    echo "======================================"

    run_pkgbuild_scan

    echo
    echo "======================================"
    echo "INSTALL HOOKS"
    echo "======================================"

    scan_install_hooks

    run_shellcheck_and_namcap

    run_history_checks "$CURRENT_PACKAGE"

    echo
    echo "======================================"
    echo "RESULT"
    echo "======================================"
    echo

    show_score

    echo

    LEVEL="$(get_score_level)"

    if (( HARD_FAILURE ))
    then

        RESULT="BLOCK"

        log_security \
            "Package failed security requirements"

    elif (( FAILURES == 0 ))
    then

        RESULT="PASS"

        log_success \
            "Package passed all checks"

    elif [[ "$LEVEL" == "GOOD" || "$LEVEL" == "EXCELLENT" ]]
    then

        RESULT="REVIEW"

        log_warn \
            "Package requires manual review"

    else

        RESULT="BLOCK"

        log_security \
            "Package failed security requirements"

    fi

    echo
    echo "Audit result: $RESULT"

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

    #
    # Save last audit always
    #

    save_last_state "$CURRENT_PACKAGE"

    cleanup_temp_workspace

    case "$RESULT" in

        PASS|REVIEW)

            return 0
            ;;

        BLOCK)

            return 1
            ;;

    esac

}

# =====================================================
# AUDIT PACKAGES
# =====================================================

audit_packages() {

    local PKG

    while read -r PKG
    do

        [[ -z "$PKG" ]] && continue

        audit_package "$PKG"

    done < <(printf '%s\n' "$@")

}

# =====================================================
# AUDIT
# =====================================================

audit() {

    [[ $# -eq 0 ]] && {

        log_error \
            "No package specified"

        return 1

    }

    audit_packages "$@"

}
