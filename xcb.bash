#! /bin/bash
##
## Generate the xcb.stub file for Chibi.
##

set -eu

xml=$1; shift

types ()
{
  echo 'cat //Typedef/@name' |
  xmllint --noout --shell "$xml" |
  sed -n 's/.*="\(xcb_.*_t\)"/\1/p' | {
    while read t; do
      s=${t%_t}
      printf '(define-c-type %s predicate: %s?)\n' "$t" "${s//_/-}"
    done
  }
}

cat <<EOF
(c-system-include "xcb/xcb.h")
$(types)
EOF
