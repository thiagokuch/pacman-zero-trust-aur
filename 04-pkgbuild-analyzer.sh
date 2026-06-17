# =====================================================
# 04-pkgbuild-analyzer.sh
# =====================================================

# =====================================================
# PKGBUILD FILE
# =====================================================

get_pkgbuild_file() {

    local FILE

    FILE="$(get_package_dir)/PKGBUILD"

    [[ -f "$FILE" ]] || {

        add_hard_failure \
            "PKGBUILD not found"

        panic \
            "PKGBUILD not found"

    }

    [[ ! -L "$FILE" ]] || {

        add_hard_failure \
            "PKGBUILD is symlink"

        panic \
            "PKGBUILD is symlink"

    }

    echo "$FILE"

}

# =====================================================
# CHECK SKIP CHECKSUMS
# =====================================================

check_skip_checksums() {

    local MATCHES
    local PKGBUILD_FILE

    PKGBUILD_FILE="$(get_pkgbuild_file)"

    MATCHES=$(
        command grep \
            -nE \
            '^[a-zA-Z0-9_]+sums=.*SKIP|SKIP' \
            "$PKGBUILD_FILE"
    )

    [[ -z "$MATCHES" ]] && return 0

    log_security \
        "SKIP checksum detected"

    echo
    echo "$MATCHES"
    echo

    add_hard_failure \
        "SKIP checksum detected"

    penalty_blacklist_pattern

    return 1

}

# =====================================================
# CHECK BLACKLIST PATTERNS
# =====================================================

check_blacklist_patterns() {

    local PATTERN
    local MATCHES
    local PKGBUILD_FILE

    PKGBUILD_FILE="$(get_pkgbuild_file)"

    for PATTERN in "${BLACKLIST_PATTERNS[@]}"
    do

        MATCHES=$(
            command grep \
                -Ein \
                "$PATTERN" \
                "$PKGBUILD_FILE"
        )

        [[ -z "$MATCHES" ]] && continue

        log_security \
            "Suspicious pattern detected"

        echo
        echo "$MATCHES"
        echo

        add_hard_failure \
            "Suspicious command pattern ($PATTERN)"

        penalty_blacklist_pattern

        return 1

    done

}

# =====================================================
# CHECK BLACKLIST DEPENDENCIES
# =====================================================

check_blacklist_dependencies() {

    local DEP
    local PKGBUILD_FILE

    PKGBUILD_FILE="$(get_pkgbuild_file)"

    for DEP in "${BLACKLIST_DEPS[@]}"
    do

        if command grep \
            -Eq \
            "(depends|makedepends)=.*${DEP}" \
            "$PKGBUILD_FILE"
        then

            log_security \
                "Blacklisted dependency detected"

            add_hard_failure \
                "Blacklisted dependency ($DEP)"

            penalty_blacklist_pattern

            return 1

        fi

    done

}

# =====================================================
# CHECK SOURCE URLS
# =====================================================

check_source_urls() {

    local URL
    local PKGBUILD_FILE

    PKGBUILD_FILE="$(get_pkgbuild_file)"

    while read -r URL
    do

        [[ -z "$URL" ]] && continue

        printf "%-25s %s\n" \
            "Source:" \
            "$URL"

    done < <(

        command grep '^source=' "$PKGBUILD_FILE" |
        command sed 's/^source=//' |
        tr '()' ' '

    )

}

# =====================================================
# RUN PKGBUILD SCAN
# =====================================================

run_pkgbuild_scan() {

    local STATUS=0

    check_source_urls

    check_skip_checksums ||
        STATUS=1

    check_blacklist_patterns ||
        STATUS=1

    check_blacklist_dependencies ||
        STATUS=1

    echo

    if (( STATUS == 0 ))
    then

        echo "PKGBUILD................. PASS"

    else

        echo "PKGBUILD................. FAIL"

    fi

    return "$STATUS"

}
