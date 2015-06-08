# replace to sed script file.
/^=sed_file$/ {
  r xml2sh.sed.tmp
  d
}

# replace to awk script file.
/^=awk_file$/ {
  r xml2sh.awk.tmp
  d
}
