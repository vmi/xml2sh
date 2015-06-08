# first line only.
1 {
  # remove BOM.
  s/^[^!-~]+//
  # XML decl.
  s/^<\?xml [^>]+\?>//
  # delete empty line.
  /^?$/d
  ###TRACE
  i\
	[no XML decl]
}

:next_cycle

###TRACE
i\
	[comment]

# remove comment.
/<!--/ {
  :comment_end
  /-->/ {
    s/<!--([^\-]|-[^\-])*-->//g
    t next_cycle
    # invalid comment format.
    b error
  }
  $! {
    # read next line.
    N
    b comment_end
  }
  a\
Incomplete comment.
  b error
}

# remove all CR.
s///g

# remove white spaces before tag.
s/^([	 ]|\n)+</</

###TRACE
i\
	[end tag]

# end tag.
/^<\// {
  :retry_end_tag_end
  />/ {
    h
    s/>.*/>/
    s/[	 ]|\n//g
    p
    g
    s/^[^>]+>//
    s/^[	 ]*(\n|$)//
    /^$/d
    b next_cycle
  }
  $! {
    # read next line
    N
    b retry_end_tag_end
  }
  a\
Incomplete end tag.
  b error
}

###TRACE
i\
	[start/empty tag]

# start/empty tag.
/^</ {
  :retry_start_tag_end
  />/ {
    /^<!DOCTYPE/ {
      ###TRACE
      i\
	[remove DOCTYPE]
      s/^<[^>]*>//
      /^$/d
      b next_cycle
    }
    h
    y/\n/ /
    s/[	 ]*(\/?>).*/\
\1/
    s/[	 ]+([^<\/>=	 ]+=("[^<>"]*"|'[^<>']*'|[^<>"'	 ]+))/\
\1/g
    p
    g
    /^[^>]+\/>/ {
      s/^[^>]+\/>//
      s/^[	 ]*(\n|$)//
      /^$/d
      b next_cycle
    }
    s/^[^>]+>//
    /^$/d
    b next_cycle
  }
  $! {
    # read next line.
    N
    b retry_start_tag_end
  }
  a\
Incomplete start/empty tag.
  b error
}

###TRACE
i\
	[content]

# content.
s/^([^<>]+)</\1\
</
P
D
q

# format error.
:error
a\
\
ERROR
q
