# =====================================================
# 09-build.sh
# =====================================================

# =====================================================
# PACKAGE FILE DETECTION
# =====================================================

find_package_file() {

    find . \
        -maxdepth 1 \
        -type f \
        -name "*.pkg.tar*" \
        | head -n1

}

# =====================================================
# BUILD PACKAGE
# =====================================================

build_package() {

    local PKG="$1"

    log_info "Preparing sandbox"

    prepare_sandbox "$(pwd)" || {

        log_security "Sandbox preparation failed"

        return 1

    }

    log_info "Building package"

    sandbox_build "$(pwd)" || {

        log_security "Build failed"

        return 1

    }

    run_post_build_analysis || {

        log_security "Post-build analysis failed"

        return 1

    }

    log_success "Build successful"

    return 0

}

# =====================================================
# VERIFY PACKAGE FILE
# =====================================================

verify_package_file() {

    local PKGFILE

    PKGFILE=$(find_package_file)

    [[ -z "$PKGFILE" ]] && {

        log_security "No package produced"

        return 1

    }

    [[ ! -f "$PKGFILE" ]] && {

        log_security "Generated package not found"

        return 1

    }

    log_success "Package generated"

    echo
    echo "$PKGFILE"
    echo

    return 0

}

# =====================================================
# VERIFY PACKAGE SIGNATURE
# =====================================================

verify_package_signature() {

    local PKGFILE

    PKGFILE=$(find_package_file)

    [[ -z "$PKGFILE" ]] && return 1

    if [[ -f "${PKGFILE}.sig" ]]
    then

        log_info "Package signature found"

    else

        log_warn "Package has no detached signature"

    fi

    return 0

}

# =====================================================
# BUILD PIPELINE
# =====================================================

run_build_pipeline() {

    local PKG="$1"

    build_package "$PKG" || return 1

    verify_package_file || return 1

    verify_package_signature || return 1

    return 0

}

# =====================================================
# BUILD ONLY
# =====================================================

build_only() {

    local PKG="$1"

    log_info "Cloning $PKG"

    aur_clone "$PKG" || return 1

    cd "$CACHE_DIR/$PKG" || return 1

    run_reputation_checks "$PKG" || return 1

    run_hash_checks "$PKG" || return 1

    run_static_analysis "$PKG" || return 1

    run_build_pipeline "$PKG" || return 1

    log_success "$PKG built successfully"

    return 0

}
