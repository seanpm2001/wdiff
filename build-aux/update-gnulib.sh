#!/bin/bash

# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

set -e

bzr clean-tree --ignored
rm -r lib/* m4/* build-aux/*.h
for i in build-aux/*; do
    [[ -L $i ]] && continue
    case "$i" in
        *.sh|*.pm|*.pl)
            ;;
        *)
            rm $i
            ;;
    esac
done
bzr revert m4/gnulib-cache.m4
autopoint --force
${GNULIB_TOOL:-gnulib-tool} --add-import "$@"
build-aux/regen-ignore.sh
./autogen.sh
./configure --enable-experimental
make -s check
bzr revert po
for i in lib/po/*.po; do
    if [[ $( bzr diff $i | grep '^[+-]' | \
             grep -vE '^[+-]#: |POT-Creation-Date' | wc -l ) -lt 3 ]]; then
        bzr revert $i
    else
        echo "$i updated."
    fi
done
bzr status
