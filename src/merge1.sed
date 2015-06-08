# insert LICENSE file at fisrt.
2 {
  a\
#
  r LICENSE.tmp
}

# remove unused part for merged file.
/^###BEGIN/,/^###END/d

# remove trace filter.
s/\| *grep -v '[^']+' *//

# convert [-f "$*_file"] to [' LF =*_file LF ']
s/ +-f +\"\$([^\"]+_file)\"/ '\
=\1\
'/g
