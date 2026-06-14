# =====================================================
# 13-audit.sh
# =====================================================

# =====================================================
# AUDIT PACKAGE
# =====================================================

audit_package() {

    local PKG="$1"
    local TMP_DIR
    local LEVEL
    local RESULT

    reset_score

    TMP_DIR="$(mktemp -d)"

    echo
    echo "======================================"
    echo "AUDITING $PKG"
    echo "======================================"
    echo

    aur_clone "$PKG" "$TMP_DIR" || {

        rm -rf "$TMP_DIR"

        return 1

    }

    enter_package_dir "$PKG" "$TMP_DIR" || {

        rm -rf "$TMP_DIR"

        return 1

    }

    run_reputation_checks "$PKG"

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

    run_history_checks "$PKG"

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

    CURRENT_AUDIT_TIME="$(get_current_audit_time)"
    CURRENT_HASH="$(get_last_commit_hash)"
    CURRENT_COMMITS="$(get_commit_count)"
    CURRENT_MAINTAINER="$(get_current_maintainer)"

    #
    # Save last audit always
    #

    save_last_state "$PKG"

    rm -rf "$TMP_DIR"

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

    for PKG in "$@"
    do

        audit_package "$PKG"

    done

}

# =====================================================
# AUDIT
# =====================================================

audit() {

    [[ $# -eq 0 ]] && {

        log_error "No package specified"

        return 1

    }

    audit_packages "$@"

}

