# Code for managing sgriege's personal dotfiles.
# Copyright (C) 2026 Simon Grieger
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

DOTFILES_DIR_DATA='data'

die() {
    [ $# -gt 0 ] && echo Error: $@ >&2
    exit 1
}

warn() {
    [ $# -gt 0 ] && echo Warning: $@ >&2
    return 0
}

get_relative_symlink_target() {
    [ $# -eq 2 ] || return 1
    local target="${1%%/}"
    local link_name="${2%%/}"

    # Make paths absolute if they are relative.
    [[ ${target}    == /* ]] || target="$(pwd)/$target"
    [[ ${link_name} == /* ]] || link_name="$(pwd)/$link_name"

    # Find a common path prefix by starting with the symlink's directory as the prefix and removing
    # path components from the end until the prefix is found at the beginning of the target
    # path. Always have a path separator at the end of the prefix to easily handle the root
    # directory as a possible prefix.
    local prefix="$(dirname "$link_name")"
    [[ $prefix == */ ]] || prefix="${prefix}/"
    local ascend_path=''
    while [[ $target != "$prefix"* ]]; do
        prefix="${prefix%/*/}/"
        ascend_path="../$ascend_path"
    done

    printf '%s%s' "$ascend_path" "${target#"$prefix"}"
}

dotfiles_clean_dir() {
    [ $# -eq 1 ] || return 1
    local dir="${HOME}/$1"

    if [ -e "$dir" ]; then
        if [ ! -d "$dir" ]; then
            warn Refusing to remove "\"$dir\"": Not a directory
            return 1
        fi

        rm -ri "$dir"
    fi

    return 0
}

dotfiles_clean_file() {
    [ $# -eq 1 ] || return 1
    local file="${HOME}/$1"

    if [ -e "$file" ]; then
        if [ ! -f "$file" ]; then
            warn Refusing to remove "\"$file\"": Not a regular file
            return 1
        fi

        rm -i "$file"
    fi

    return 0
}

dotfiles_create_dir() {
    [ $# -eq 1 ] || return 1
    mkdir -p "${HOME}/$1" || die
    return 0
}

dotfiles_install_file() {
    [ $# -eq 1 ] || return 1
    local dotfile="$1"
    local dotfile_src="data/${dotfile}"
    local dotfile_dst="${HOME}/${dotfile}"
    local symlink_target="$(get_relative_symlink_target "$dotfile_src" "$dotfile_dst")"

    [ -f "$dotfile_src" ] || die "\"$dotfile_src\"" does not exist or is not a regular file

    if [ -L "$dotfile_dst" ]; then
        # Don't recreate the symlink if a correct one is already in place. Remove it if it points to
        # the wrong location.
        if [ "$(readlink -n "$dotfile_dst")" = "$symlink_target" ]; then
            return 0
        else
            rm -i "$dotfile_dst"
        fi
    elif [ -f "$dotfile_dst" ]; then
        rm -i "$dotfile_dst"
    elif [ -e "$dotfile_dst" ]; then
        die "\"$dotfile_dst\"" already exists, but is neither a symbolic link nor a regular file
    fi

    # Warn if an already existing file has not been removed.
    if [ -e "$dotfile_dst" ]; then
        warn "\"$dotfile_dst\"" will be left unmodified
        return 1
    fi

    mkdir -p "$(dirname "$dotfile_dst")" || die
    ln -s "$symlink_target" "$dotfile_dst" || die

    return 0
}

dotfiles_install_all() {
    [ $# -eq 0 ] || return 1

    local file
    while IFS='' read -d '' -r file <&3; do
        dotfiles_install_file "${file#${DOTFILES_DIR_DATA}/}"
    done 3< <(find "$DOTFILES_DIR_DATA" -type f -print0 | sort -z)

    return 0
}

dotfiles_make() {
    # Even though macOS comes with GNU Make by default, it is installed solely as "make"; there is
    # no "gmake" (sym)linked to "make".
    local make='gmake'
    [ "$(uname)" = 'Darwin' ] && make='make'
    $make "$@"
}
