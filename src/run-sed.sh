#!/bin/bash

set -eu

if [ $# == 0 ]; then
  files=$(echo test-data/*.xml)
else
  files="$*"
fi

for f in $files; do
  echo "[$f]"
  echo "------------------------------------------------------------------------------"
  sed -E -f xml2sh.sed "$f"
  echo "------------------------------------------------------------------------------"
  echo ""
done
