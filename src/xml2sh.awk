# Local Variables:
# c-basic-offset: 2
# indent-tabs-mode: nil
# End:

function abort(msg) {
  print prefix "_ERROR=true"
  if (msg != "") {
    gsub(/\047/, "\047\\\047\047", msg)
    print prefix "_ERROR_MESSAGE=\047" msg "\047"
  }
  exit 1
}

function add_child(tag, key) {
  if (key == "")
    key = get_key()
  tag = "<" tag ">"
  if (!index(children[key], tag))
    children[key] = children[key] tag
}

function remove_child(tag, key) {
  if (key == "")
    key = get_key()
  tag = "<" tag ">"
  sub(tag, "", children[key])
}

# tag: tag name.
# key: local variable.
function push_tag(tag, key) {
  if (ndx) {
    if (tags[ndx - 1] == tag "s") {
      --ndx
      key = get_key(ndx - 1)
      remove_child(reduction[ndx] = tags[ndx], key)
    } else {
      key = get_key(ndx - 1)
    }
    add_child(tag, key)
    key = key sep_tag tag
  } else {
    key = tag
  }
  tag_indexes[key]++
  tags[ndx++] = tag
}

function pop_tag() {
  if (ndx)
    delete children[get_key()]
  if (reduction[ndx - 1]) {
    tags[ndx - 1] = reduction[ndx - 1]
    delete reduction[ndx - 1]
  } else {
    delete tags[--ndx]
  }
}

# i: index
function get_base_key(i) {
  if (ndx == 0)
    abort("no key")
  if (i == "")
    i = ndx - 1
  return i ? (get_key(i - 1) sep_tag tags[i]) : prefix
}

# i: index
# key: local variable
function get_key(i, key) {
  key = get_base_key(i)
  if (tag_indexes[key] <= 1)
    return key
  else
    return key sep_ndx tag_indexes[key]
}

function key2var(key) {
  gsub(/[^A-Za-z0-9_]/, non_word_char, key)
  return key
}

function print_entry(i, key) {
  key = get_key()
  if ((i = ++text_indexes[key]) > 1)
    key = key sep_ndx i
  gsub(/\047/, "\047\\\047\047", value)
  print key2var(key) "=\047" value "\047"
  value = ""
}

BEGIN {
  if ((prefix = ENVIRON["XML2SH_PREFIX"]) == "")
    prefix = "xml2sh"
  if ((sep_tag = ENVIRON["XML2SH_SEP_TAG"]) == "")
    sep_tag = "_"
  if ((sep_atr = ENVIRON["XML2SH_SEP_ATR"]) == "")
    sep_atr = "_"
  if ((sep_ndx = ENVIRON["XML2SH_SEP_NDX"]) == "")
    sep_ndx = "_"
  if ((non_word_char = ENVIRON["XML2SH_NON_WORD_CHAR"]) == "")
    non_word_char = "_"

  # current tags:
  #   tags[LEVEL] = TAG_NAME (n >= 0)
  #
  # indexes of each tags:
  #   tag_indexes[PARENT_LEVEL,TAG_NAME] = LAST_INDEX
  # <list>
  #   <item>A</item>
  #   <item>B</item>
  #   <item>C</item>
  # </list>
  # =>
  # list_item=A    tags=[0:"list",1:"item"], children=["list":"item"], tag_indexes=["list_item":1]
  # list_item_2=B  tags=[0:"list",1:"item"], tag_indexes=["list_item":2]
  # list_item_3=C  tags=[0:"list",1:"item"], tag_indexes=["list_item":3]
  #
  # <b>A<i>B</i>C<hr/>D</b>
  # b=A     text_indexes["b":1]
  # b_i=B
  # b_2=C   text_indexes["b":2]
  # b_hr=''
  # b_3=D   text_indexes["b":3]
  #
  # current mode:
  #   mode = 0 top level
  #   mode = 1 parsing start tag.
  #   mode = 2 parsed start tag.
  #   mode = 3 parsed end tag.
  ndx = 0
  mode = 0
  in_content = 0
  value = ""
}

# end tag.
match($0, /^<\/[^<>\t ]+>/) {
  in_content = 0
  if (mode < 2)
    abort("Invalid end tag.")
  else if (mode == 2) {
    print_entry()
    mode = 3
  } else {
    # mode == 3
    if (length(value) && !match(value, /^[ \t\n]*$/))
      print_entry()
    key = get_key()
    split(children[key], cr, /><|[<>]/)
    for (i = 2; i < length(cr); i++) {
      c = cr[i]
      ck = key sep_tag c
      if ((ci = tag_indexes[ck]) > 1)
        print key2var(ck) "___LAST_INDEX=" ci
    }
    if ((i = text_indexes[key]) > 1)
      print key2var(key) "___LAST_INDEX=" i
  }
  pop_tag()
  next
}

# start tag.
match($0, /^<[^ \t<>]+/) {
  tag = substr($0, RSTART + 1, RLENGTH - 1)
  if (length(value) && !match(value, /^[ \t\n]*$/))
    print_entry()
  in_content = 0
  mode = 1
  push_tag(tag)
  next
}

# in start tag.
mode == 1 {
  if ($0 == ">") {
    mode = 2
  } else if ($0 == "/>") {
    print_entry()
    pop_tag()
    mode = 3
  } else {
    eq = index($0, "=")
    akey = substr($0, 1, eq - 1)
    aval = substr($0, eq + 1)
    gsub(/^["\047]|["\047]$/, "", aval)
    gsub(/\047/, "\047\\\047\047", aval)
    print key2var(get_key() sep_atr akey) "=\047" aval "\047"
  }
  next
}

# content
{
  if (in_content) {
    value = value "\n" $0
  } else {
    value = $0
    in_content = 1
  }
}
