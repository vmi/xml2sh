xml2sh: test Makefile xml2sh.sh xml2sh.sed xml2sh.awk
	sed '$$d; s/^/# /' ../LICENSE > LICENSE.tmp
	for f in xml2sh.sed xml2sh.awk; do \
	  sed -E -f strip.sed $$f > $$f.tmp; \
	done
	sed -E -f merge1.sed xml2sh.sh | sed -E -f merge2.sed > xml2sh
	rm -f *.tmp
	diff -u ../xml2sh xml2sh || true

install:: xml2sh
	mv -v xml2sh ..

test::
	./test-sed.sh
	./test-awk.sh
