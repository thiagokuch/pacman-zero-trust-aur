# =====================================================
# 05-install-hook.sh
# =====================================================

INSTALL_BLACKLIST_PATTERNS=(
"curl"
"wget"
"eval"
"base64 -d"
"xxd -r"
"openssl enc"
"python -c"
"perl -e"
"ruby -e"
"lua -e"
"nc "
"ncat"
"socat"
"mkfifo"
"/dev/tcp"
"systemctl enable"
"systemctl start"
"crontab"
"at "
"nohup"
)

# =====================================================
# FIND INSTALL FILES
# =====================================================

find_install_files() {

    command find \
        "$(get_package_dir)" \
        -xdev \
        -type f \
        ! -type l \
        \( \
            -name '*.install' \
            -o \
            -name '*.INSTALL' \
        \)

}

# =====================================================
# SCAN INSTALL HOOKS
# =====================================================

scan_install_hooks() {

    local FILE
    local PATTERN
    local STATUS=0
    local FILES

    echo

    FILES="$(find_install_files)"

    if [[ -z "$FILES" ]]
    then

        echo "Install hooks............ PASS"

        return 0

    fi

    while read -r FILE
    do

        [[ -z "$FILE" ]] && continue

        [[ -L "$FILE" ]] && {

            log_security \
                "Install hook is symlink"

            add_hard_failure \
                "Install hook is symlink"

            penalty_hooks

            STATUS=1

            continue

        }

        echo "Inspecting $(basename "$FILE")"

        for PATTERN in "${INSTALL_BLACKLIST_PATTERNS[@]}"
        do

            if command grep \
                -Fqi \
                "$PATTERN" \
                "$FILE"
            then

                log_security \
                    "Suspicious command found in $(basename "$FILE")"

                add_hard_failure \
                    "Suspicious install hook ($PATTERN)"

                penalty_hooks

                STATUS=1

            fi

        done

    done <<< "$FILES"

    echo

    if (( STATUS == 0 ))
    then

        echo "Install hooks............ PASS"

    else

        echo "Install hooks............ FAIL"

    fi

    return "$STATUS"

}
