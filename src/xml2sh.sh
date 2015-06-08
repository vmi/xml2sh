#!/bin/sh
# -*- coding: raw-text -*-

###BEGIN
bin_path="${0%/*}"
sed_file="$bin_path/xml2sh.sed"
awk_file="$bin_path/xml2sh.awk"

###END
export XML2SH_PREFIX="${XML2SH_PREFIX:-xml2sh}"
export XML2SH_SEP_TAG="${XML2SH_SEP_TAG:-_}"
export XML2SH_SEP_ATR="${XML2SH_SEP_ATR:-_}"
export XML2SH_SEP_NDX="${XML2SH_SEP_NDX:-_}"
export XML2SH_NON_WORD_CHAR="${XML2SH_NON_WORD_CHAR:-_}"

xml2sh_help() {
  echo "XML to shell script converter.

Usage: xml2sh [XML_FILE]

  Use standard input if no XML_FILE.

Environment Variables:
  XML2SH_PREFIX: the prefix of variables. \"$XML2SH_PREFIX\"
  XML2SH_SEP_TAG: the separator between tags. \"$XML2SH_SEP_TAG\"
  XML2SH_SEP_ATR: the separator between tag and attribute. \"$XML2SH_SEP_ATR\"
  XML2SH_SEP_NDX: the separator between tag and index. \"$XML2SH_SEP_NDX\"
  XML2SH_NON_WORD_CHAR: the replacement of non-word characters. \"$XML2SH_NON_WORD_CHAR\"
"
  exit 1
}

# Usage: xml2sh_unset PREFIX SEP
xml2sh_unset() {
  local prefix="${1:-$XML2SH_PREFIX}"
  local sep="${2:-$XML2SH_SEP_TAG}"
  unset $(set | sed -n -E "/^$prefix$sep[A-Za-z0-9_]+=/ { s/=.*//; p; }")
}

# Usage: xml2sh_get NEW_PREFIX BASE_NAME n
xml2sh_get() {
  local new_prefix="$1"
  local base_name="$2"
  local atr=""
  if [ "$3" -gt 1 ]; then
    atr="$XML2SH_SEP_ATR$1"
  fi
  local n
  for n in $(set | sed -n -E "s/^$base_name$atr($XML2SH_SEP_TAG[A-Za-z_][A-Za-z0-9_]*)=.*/\1/
    t print_name
    b
    :print_name
    p"); do
    eval "${new_prefix}$n=\"\$$base_name$atr$n\""
  done
}

# Usage: xml2sh_each NEW_PREFIX BASE_NAME EXPR ...
xml2sh_each() {
  local new_prefix="$1"; shift
  local base_name="$1";  shift
  eval "local last_index=\"\$${base_name}___LAST_INDEX"
  local i
  for i in $(seq 1 $last_index); do
    xml2sh_get $new_prefix $base_name $i
    if "$@"; then
      break
    fi
    xml2sh_unset $new_prefix
  done
}

xml2sh() {
  case "#{1:-}" in
    -h|--help)
      xml2sh_help
      ;;
  esac
  LANG=C sed -E -f "$sed_file" "$@" | grep -v '^' | LANG=C awk -f "$awk_file"
}

if [ "${0##*/}" = "xml2sh" ]; then
  xml2sh "$@"
fi
