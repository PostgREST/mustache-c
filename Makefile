PREFIX ?= /usr/local

CFLAGS = -std=c99 -Iinclude -fPIC -DHELPERS=1 -DDEBUG=1

LDFLAGS = -Lbuild -lmustache_c

SOFLAGS = -shared -Wl,-soname,libmustache_c.so

# build

lib: build/libmustache_c.so

build/libmustache_c.so : build/parser.tab.o build/parser.lex.o include/mustache-internal.h include/mustache.h include/parser.tab.h
	$(CC) $(CFLAGS) ${SOFLAGS} build/parser.tab.o build/parser.lex.o -o $@

build/parser.lex.o : build/parser.lex.c include/parser.tab.h

dir_guard=@mkdir -p build

include/parser.tab.h build/parser.tab.c : src/parser.y
	$(dir_guard)
	bison -p mustache_p_ -b parser $? --header=include/parser.tab.h -o build/parser.tab.c

build/parser.lex.c : src/parser.l
	$(dir_guard)
	flex -t $? > $@

.PHONY: clean
clean:
	rm -rf build
	rm -f  include/parser.tab.h

# tests

build/test : test/test.c build/libmustache_c.so
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ test/test.c

.PHONY: check
check: build/test
	LD_LIBRARY_PATH=build ./build/test

# examples

build/array : examples/array.c build/libmustache_c.so
	$(CC) $(CFLAGS) $(LDFLAGS) -DTPL_PATH='"build/"' -o $@ examples/array.c

build/array.template: examples/array.template
	cp $? $@

.PHONY: exarray
.SILENT: exarray
exarray: build/array build/array.template
	LD_LIBRARY_PATH=./build ./build/array

build/simple : examples/simple.c build/libmustache_c.so
	$(CC) $(CFLAGS) $(LDFLAGS) -DTPL_PATH='"build/"' -o $@ examples/simple.c

build/simple.template: examples/simple.template
	cp $? $@

.PHONY: exsimple
.SILENT: exsimple
exsimple: build/simple build/simple.template
	LD_LIBRARY_PATH=./build ./build/simple

# install

build/mustache_c.pc: build/libmustache_c.so mustache_c.pc
	cp mustache_c.pc build/mustache_c.pc
	sed -i '1i\prefix=$(PREFIX)' build/mustache_c.pc

.PHONY: install
install: build/mustache_c.pc
	install -d -m645 $(DESTDIR)$(PREFIX)/lib/pkgconfig
	install -d -m645 $(DESTDIR)$(PREFIX)/include
	install -m755 build/libmustache_c.so $(DESTDIR)$(PREFIX)/lib
	install -m644 include/mustache.h $(DESTDIR)$(PREFIX)/include/mustache.h
	install -m644 build/mustache_c.pc $(DESTDIR)$(PREFIX)/lib/pkgconfig/mustache_c.pc
