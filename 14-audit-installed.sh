# =====================================================
# 14-audit-installed.sh
# =====================================================

# =====================================================
# AUDIT INSTALLED PACKAGE
# =====================================================

audit_installed_package() {

    local PKG="$1"

    printf "%-40s" "$PKG"

    cleanup_temp_workspace

    audit_package "$PKG" >/dev/null 2>&1 || {

        echo "BLOCK"

        cleanup_temp_workspace

        return 1

    }

    cleanup_temp_workspace

    echo "OK"

}

# =====================================================
# AUDIT INSTALLED PACKAGES
# =====================================================

audit_installed() {

    local PKG

    echo
    echo "======================================"
    echo "AUDITING MANAGED PACKAGES"
    echo "======================================"
    echo

    while read -r PKG
    do

        [[ -z "$PKG" ]] && continue

        audit_installed_package "$PKG"

    done < <(list_managed_packages)

    echo

    audit_summary

}

# =====================================================
# SHOW MANAGED COUNT
# =====================================================

show_managed_count() {

    local COUNT

    COUNT=$(list_managed_packages | wc -l)

    echo
    echo "Managed packages: $COUNT"
    echo

}

# =====================================================
# SUMMARY
# =====================================================

audit_summary() {

    echo
    echo "======================================"
    echo "SUMMARY"
    echo "======================================"

    show_managed_count

    echo

}
