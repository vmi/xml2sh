# remove trace part.
/^[	 ]*###TRACE/ {
  N
  s/^.*\n//
  /^[	 ]*i\\$/ {
    :trace_next_line
    N
    s/^.*\n//
    /\\$/b trace_next_line
    d
  }
}

# escape single quote.
s/'/'\\''/g

# has trailing backslash
/\\$/ {
  :repeat
  N
  /\\$/b repeat
  p
  d
}

# empty or comment line
/^[	 ]*(#.*)?$/d
