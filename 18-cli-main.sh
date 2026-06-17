# =====================================================

# 18-cli-main.sh

# =====================================================

# =====================================================

# HELP

# =====================================================

show_help() {

cat <<EOF

pacman-zta Zero Trust Edition $VERSION

Usage:

```
pacman-zta install <pkg...>
pacman-zta remove <pkg...>
pacman-zta update

pacman-zta status <pkg>
pacman-zta list

pacman-zta clean
pacman-zta full-clean

pacman-zta audit <pkg...>
pacman-zta audit-installed

pacman-zta doctor
pacman-zta version
pacman-zta help
```

Run without arguments to enter interactive mode.

EOF

}

# =====================================================

# INTERACTIVE MENU

# =====================================================

interactive_menu() {

```
local PKGS
local PKG

echo
echo "==========================================="
echo "pacman-zta Zero Trust Edition $VERSION"
echo "==========================================="
echo

PS3="Select an option: "

select OPTION in \
    "Install package(s)" \
    "Remove package(s)" \
    "Update system" \
    "Audit package(s)" \
    "Audit installed packages" \
    "List managed packages" \
    "Package status" \
    "Doctor" \
    "Version" \
    "Help" \
    "Exit"
do

    case "$REPLY" in

        1)

            read -ra PKGS

            install_packages "${PKGS[@]}"

            break

            ;;

        2)

            read -ra PKGS

            for PKG in "${PKGS[@]}"
            do

                remove_package "$PKG"

            done

            break

            ;;

        3)

            update_system

            break

            ;;

        4)

            read -ra PKGS

            audit "${PKGS[@]}"

            break

            ;;

        5)

            audit_installed

            break

            ;;

        6)

            show_all_managed_packages

            break

            ;;

        7)

            read -rp "Package: " PKG

            show_package_status "$PKG"

            break

            ;;

        8)

            doctor

            break

            ;;

        9)

            show_version

            break

            ;;

        10)

            show_help

            break

            ;;

        11)

            break

            ;;

        *)

            echo "Invalid option"

            ;;

    esac

done
```

}

# =====================================================

# PARSERS

# =====================================================

parse_install() {

```
shift

[[ $# -gt 0 ]] || {

    log_error "No package specified"

    return 1

}

install_packages "$@"
```

}

parse_remove() {

```
shift

[[ $# -gt 0 ]] || {

    log_error "No package specified"

    return 1

}

local PKG

for PKG in "$@"
do

    remove_package "$PKG"

done
```

}

parse_status() {

```
shift

[[ $# -eq 1 ]] || {

    log_error "Specify one package"

    return 1

}

show_package_status "$1"
```

}

parse_list() {

```
show_all_managed_packages
```

}

parse_clean() {

```
clean_cache
```

}

parse_full_clean() {

```
full_clean
```

}

parse_audit() {

```
shift

[[ $# -gt 0 ]] || {

    log_error "No package specified"

    return 1

}

audit "$@"
```

}

parse_audit_installed() {

```
audit_installed
```

}

parse_update() {

```
update_system
```

}

parse_doctor() {

```
doctor
```

}

parse_version() {

```
show_version
```

}

# =====================================================

# MAIN

# =====================================================

main() {

```
require_non_root

if [[ $# -eq 0 ]]
then

    interactive_menu

    return 0

fi

case "$1" in

    install)

        parse_install "$@"

        ;;

    remove)

        parse_remove "$@"

        ;;

    update)

        parse_update

        ;;

    status)

        parse_status "$@"

        ;;

    list)

        parse_list

        ;;

    clean)

        parse_clean

        ;;

    full-clean)

        parse_full_clean

        ;;

    audit)

        parse_audit "$@"

        ;;

    audit-installed)

        parse_audit_installed

        ;;

    doctor)

        parse_doctor

        ;;

    version)

        parse_version

        ;;

    help)

        show_help

        ;;

    *)

        log_error "Unknown command"

        echo

        show_help

        return 1

        ;;

esac
```

}

main "$@"
exit $?
