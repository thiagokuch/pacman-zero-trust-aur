# =====================================================
# 04-pkgbuild-analyzer.sh
# =====================================================

# =====================================================
# CHECK SKIP CHECKSUMS
# =====================================================

check_skip_checksums() {

    local MATCHES

    MATCHES=$(
        grep -nE \
            '^[a-zA-Z0-9_]+sums=.*SKIP|SKIP' \
            PKGBUILD
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

    for PATTERN in "${BLACKLIST_PATTERNS[@]}"
    do

        MATCHES=$(
            grep -Ein "$PATTERN" PKGBUILD
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

    for DEP in "${BLACKLIST_DEPS[@]}"
    do

        if grep -Eq "(depends|makedepends)=.*${DEP}" PKGBUILD
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

    while read -r URL
    do

        [[ -z "$URL" ]] && continue

        printf "%-25s %s\n" \
            "Source:" \
            "$URL"

    done < <(

        grep '^source=' PKGBUILD |
        sed 's/^source=//' |
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
