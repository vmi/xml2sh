#!/bin/bash

set -eu

error=false

if [ $# == 0 ]; then
  files=$(echo test-data/*.txt)
else
  files="$*"
fi

for f in $files; do
  echo "[$f]"
  echo "------------------------------------------------------------------------------"
  if diff -u ${f%.*}.sh <(awk -f xml2sh.awk "$f"); then
    echo "SUCCESS"
  else
    error=true
  fi
  echo "------------------------------------------------------------------------------"
  if $error; then
    echo "FAILED"
    exit 1
  fi
  echo ""
done
