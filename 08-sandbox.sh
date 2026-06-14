# =====================================================
# 08-sandbox.sh
# =====================================================

# Dedicated build user
AUR_BUILDER_USER="aurbuilder"

# =====================================================
# BUILDER USER
# =====================================================

ensure_builder_user() {

    if ! id "$AUR_BUILDER_USER" >/dev/null 2>&1
    then

        log_warn "Creating build user $AUR_BUILDER_USER"

        sudo useradd \
            --system \
            --create-home \
            --shell /usr/bin/nologin \
            "$AUR_BUILDER_USER"

    fi

}

# =====================================================
# PREPARE BUILD DIRECTORY
# =====================================================

prepare_build_directory() {

    local DIR="$1"

    sudo chown -R "$AUR_BUILDER_USER:$AUR_BUILDER_USER" "$DIR"

}

# =====================================================
# PREFETCH SOURCES
# =====================================================

prefetch_sources() {

    log_info "Prefetching sources"

    sudo -u "$AUR_BUILDER_USER" \
        makepkg \
        --nobuild \
        --syncdeps \
        --noconfirm

}

# =====================================================
# SANDBOX BUILD
# =====================================================

sandbox_build() {

    local WORKDIR="$1"

    log_info "Starting sandboxed offline build"

    systemd-run \
        --wait \
        --collect \
        --quiet \
        -p DynamicUser=no \
        -p User="$AUR_BUILDER_USER" \
        -p Group="$AUR_BUILDER_USER" \
        -p PrivateNetwork=yes \
        -p PrivateTmp=yes \
        -p PrivateDevices=yes \
        -p ProtectSystem=strict \
        -p ProtectHome=yes \
        -p ProtectKernelModules=yes \
        -p ProtectKernelTunables=yes \
        -p ProtectControlGroups=yes \
        -p ProtectClock=yes \
        -p ProtectHostname=yes \
        -p ProtectProc=invisible \
        -p ProcSubset=pid \
        -p RestrictSUIDSGID=yes \
        -p RestrictRealtime=yes \
        -p RestrictNamespaces=yes \
        -p NoNewPrivileges=yes \
        -p MemoryDenyWriteExecute=yes \
        -p LockPersonality=yes \
        -p RemoveIPC=yes \
        -p PrivateUsers=yes \
        -p UMask=0077 \
        -p CapabilityBoundingSet= \
        -p IPAddressDeny=any \
        -p SystemCallArchitectures=native \
        -p RestrictAddressFamilies=AF_UNIX \
        bash -c "
            cd '$WORKDIR' &&
            makepkg -e --noconfirm
        "

}

# =====================================================
# CLEANUP
# =====================================================

sandbox_cleanup() {

    find "$CACHE_DIR" \
        -mindepth 1 \
        -maxdepth 1 \
        -type d \
        -mtime +30 \
        -exec rm -rf {} +

}

# =====================================================
# COMPLETE SANDBOX PIPELINE
# =====================================================

prepare_sandbox() {

    local DIR="$1"

    ensure_builder_user || return 1

    prepare_build_directory "$DIR" || return 1

    prefetch_sources || return 1

    return 0

}
