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

dotfiles_make_dir() {
    [ $# -eq 1 ] || return 1
    mkdir -p "${HOME}/$1" || die
    return 0
}

dotfiles_install_file() {
    [ $# -eq 1 ] || return 1
    local dotfile="$1"
    local dotfile_src="data/${dotfile}"
    local dotfile_dst="${HOME}/${dotfile}"

    [ -f "$dotfile_src" ] || die "\"$dotfile_src\"" does not exist or is not a regular file

    if [ -L "$dotfile_dst" ]; then
        # Don't recreate the symlink if a correct one is already in place. Remove it if it points to
        # the wrong location.
        if [ "$(readlink -mn "$dotfile_dst")" = "$(realpath -m "$dotfile_src")" ]; then
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
    ln -sr "$dotfile_src" "$dotfile_dst" || die

    return 0
}

dotfiles_install_all() {
    [ $# -eq 0 ] || return 1

    local file
    while IFS='' read -d '' -r file <&3; do
        dotfiles_install_file "${file#${DOTFILES_DIR_DATA}/}"
    done 3< <(find "$DOTFILES_DIR_DATA" -type f -print0 | sort)

    return 0
}
