# =====================================================
# 09-build.sh
# =====================================================

# =====================================================
# PACKAGE FILE DETECTION
# =====================================================

find_package_file() {

    command find \
        "$(get_package_dir)" \
        -maxdepth 1 \
        -type f \
        ! -type l \
        -name "*.pkg.tar*" |
    head -n1

}

# =====================================================
# BUILD PACKAGE
# =====================================================

build_package() {

    log_info "Preparing sandbox"

    prepare_sandbox || {

        log_security \
            "Sandbox preparation failed"

        return 1

    }

    log_info "Building package"

    sandbox_build || {

        log_security \
            "Build failed"

        return 1

    }

    run_post_build_analysis || {

        log_security \
            "Post-build analysis failed"

        return 1

    }

    log_success "Build successful"

}

# =====================================================
# VERIFY PACKAGE FILE
# =====================================================

verify_package_file() {

    local PKGFILE

    PKGFILE="$(find_package_file)"

    [[ -n "$PKGFILE" ]] || {

        log_security \
            "No package produced"

        return 1

    }

    [[ -f "$PKGFILE" ]] || {

        log_security \
            "Generated package not found"

        return 1

    }

    log_success \
        "Package generated"

    echo
    echo "$PKGFILE"
    echo

}

# =====================================================
# VERIFY PACKAGE SIGNATURE
# =====================================================

verify_package_signature() {

    local PKGFILE

    PKGFILE="$(find_package_file)"

    [[ -n "$PKGFILE" ]] || return 1

    if [[ -f "${PKGFILE}.sig" ]]
    then

        log_info \
            "Package signature found"

    else

        log_warn \
            "Package has no detached signature"

    fi

}

# =====================================================
# BUILD PIPELINE
# =====================================================

run_build_pipeline() {

    build_package ||
        return 1

    verify_package_file ||
        return 1

    verify_package_signature ||
        return 1

}

# =====================================================
# BUILD ONLY
# =====================================================

build_only() {

    CURRENT_PACKAGE="$1"

    log_info \
        "Cloning $CURRENT_PACKAGE"

    safe_git_clone ||
        return 1

    run_reputation_checks ||
        return 1

    run_hash_checks ||
        return 1

    run_static_analysis ||
        return 1

    run_build_pipeline ||
        return 1

    log_success \
        "$CURRENT_PACKAGE built successfully"

}
