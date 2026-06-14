# =====================================================
# 06-shellcheck-namcap.sh
# =====================================================

# =====================================================
# SHELLCHECK
# =====================================================

run_shellcheck() {

    local FILES

    FILES=$(find . -type f)

    shellcheck $FILES >/tmp/pacman-zta-shellcheck.log 2>&1

    if [[ $? -ne 0 ]]
    then

        log_security "shellcheck failed"

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

    namcap PKGBUILD >/tmp/pacman-zta-namcap.log 2>&1

    if [[ $? -ne 0 ]]
    then

        log_security "namcap failed"

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
