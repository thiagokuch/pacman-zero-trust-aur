# =====================================================
# 01-foundation.sh
# =====================================================

VERSION="0.1.0"

# =====================================================
# DIRECTORIES
# =====================================================

STATE_DIR="$HOME/.local/share/pacman-zta/state"
CONFIG_FILE="$HOME/.config/pacman-zta.conf"

mkdir -p "$STATE_DIR"

# =====================================================
# ROOT PROTECTION
# =====================================================

require_non_root() {

    if [[ "$EUID" -eq 0 ]]
    then

        log_error "pacman-zta must not be run as root."

        echo >&2
        echo "Current user : $(id -un)" >&2
        echo "Current HOME : $HOME" >&2
        echo >&2
        echo "Run pacman-zta as your normal user." >&2
        echo >&2

        exit 1

    fi

    if [[ "$HOME" == "/root" ]]
    then

        log_error "pacman-zta must not use /root as HOME."

        echo >&2
        echo "Current user : $(id -un)" >&2
        echo "Current HOME : $HOME" >&2
        echo >&2

        exit 1

    fi

}

# =====================================================
# SUDO KEEPALIVE
# =====================================================

sudo_keepalive() {

    sudo -v || {

        log_error "Unable to obtain sudo privileges."

        exit 1

    }

}

# =====================================================
# DEFAULT POLICY
# =====================================================

MIN_AGE_DAYS=90
MIN_VOTES=10
MIN_POPULARITY=1.0

# =====================================================
# LOAD CONFIG
# =====================================================

if [[ -f "$CONFIG_FILE" ]]
then

    # shellcheck disable=SC1090
    source "$CONFIG_FILE"

fi

# =====================================================
# BLOCKED PACKAGE SUFFIXES
# =====================================================

BLOCKED_SUFFIXES=(
-git
-svn
-hg
-nightly
-alpha
-beta
-rc
)

# =====================================================
# BLOCKED DEPENDENCIES
# =====================================================

BLACKLIST_DEPS=(
npm
bun
)

# =====================================================
# BLACKLIST PATTERNS
# =====================================================

BLACKLIST_PATTERNS=(
"curl.+\|.+bash"
"wget.+\|.+sh"
"curl -fsSL"
"wget -q"
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
)

# =====================================================
# COLORS
# =====================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# =====================================================
# TIMESTAMP
# =====================================================

timestamp() {

    date "+%Y-%m-%d %H:%M:%S"

}

# =====================================================
# LOGGING
# =====================================================

log_info() {

    echo -e "${BLUE}[$(timestamp)] [INFO]${NC} $*"

}

log_warn() {

    echo -e "${YELLOW}[$(timestamp)] [WARNING]${NC} $*" >&2

}

log_error() {

    echo -e "${RED}[$(timestamp)] [ERROR]${NC} $*" >&2

}

log_security() {

    echo -e "${RED}[$(timestamp)] [SECURITY_BLOCK]${NC} $*" >&2

}

log_success() {

    echo -e "${GREEN}[$(timestamp)] [OK]${NC} $*"

}

# =====================================================
# VERSION
# =====================================================

show_version() {

    echo "pacman-zta Zero Trust Edition $VERSION"

}
