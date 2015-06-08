#!/bin/bash

set -eu

for f in test-data/*.txt; do
  echo "[$f]"
  echo "------------------------------------------------------------------------------"
  awk -f xml2sh.awk "$f"
  echo "------------------------------------------------------------------------------"
  echo ""
done
