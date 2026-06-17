# =====================================================
# 06-shellcheck-namcap.sh
# =====================================================

# =====================================================
# SHELLCHECK FILES
# =====================================================

get_shellcheck_files() {

    local PKG_DIR

    PKG_DIR="$(get_package_dir)"

    command find \
        "$PKG_DIR" \
        -xdev \
        -type f \
        ! -type l \
        \
        \( \
            -name '*.sh' \
            -o -name '*.install' \
            -o -name 'PKGBUILD' \
        \)

}

# =====================================================
# SHELLCHECK
# =====================================================

run_shellcheck() {

    local STATUS=0
    local FILE

    while read -r FILE
    do

        [[ -z "$FILE" ]] && continue

        if ! command shellcheck \
            "$FILE" \
            >>"$CACHE_DIR/shellcheck.log" \
            2>&1
        then

            STATUS=1

        fi

    done < <(get_shellcheck_files)

    if (( STATUS ))
    then

        log_security \
            "shellcheck failed"

        add_hard_failure \
            "Shellcheck detected errors"

        penalty_shellcheck

        return 1

    fi

    echo "Shellcheck............... PASS"

}

# =====================================================
# NAMCAP
# =====================================================

run_namcap() {

    local PKGBUILD_FILE

    PKGBUILD_FILE="$(get_pkgbuild_file)"

    if ! command namcap \
        "$PKGBUILD_FILE" \
        >"$CACHE_DIR/namcap.log" \
        2>&1
    then

        log_security \
            "namcap failed"

        add_hard_failure \
            "Namcap detected issues"

        penalty_namcap

        return 1

    fi

    echo "Namcap................... PASS"

}

# =====================================================
# SHELLCHECK + NAMCAP
# =====================================================

run_shellcheck_and_namcap() {

    local STATUS=0

    echo
    echo "======================================"
    echo "SHELLCHECK / NAMCAP"
    echo "======================================"

    run_shellcheck ||
        STATUS=1

    run_namcap ||
        STATUS=1

    echo

    if (( STATUS == 0 ))
    then

        echo "SHELLCHECK / NAMCAP...... PASS"

    else

        echo "SHELLCHECK / NAMCAP...... FAIL"

    fi

    return "$STATUS"

}
