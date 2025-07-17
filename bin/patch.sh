#!/usr/bin/env bash

PROJECT_ROOT=$(git rev-parse --show-toplevel)
PATCH_DIR=$PROJECT_ROOT/patches
DST=$PROJECT_ROOT/hugo
CMD=

find_patches() {
    find "$PATCH_DIR" -name "*.patch"
}


check_patches() {
    find_patches | xargs git -C "$DST" apply --check
    info_or_error $? "Patches are not compatible." "Patches can be applied."
}

apply_patches() {
    info "Applying patches..."
    find_patches | xargs git -C "$DST" apply
    info_or_error $? "Patches are not applied." "Patches are applied."
}

main() {
    CMD=$1
    shift

    case $CMD in
        check)
            check_patches
            ;;
        apply)
            check_patches
            apply_patches
            ;;
        *)
            echo "== ERROR: Invalid command: $CMD"
            exit 1
    esac
}

info() {
    print_info "INFO" "$1"
}

error() {
    print_info "ERROR" "$1"
}

print_info() {
    local level=$1
    local msg=$2
    
    if [ "$level" == "INFO" ]; then
        color=32
    elif [ "$level" == "ERROR" ]; then
        color=31
    fi

    echo -e "\033[${color}m== ${level}: ${msg}\033[0m; '$DST' (${GIT_DESCRIBE})"
}

info_or_error() {
    local error=$1
    local error_msg=$4
    local success_msg=$3
    if [ $error -ne 0 ]; then
        error "$error_msg"
        exit 1
    else
        info "$success_msg"
    fi
}

main "$@"