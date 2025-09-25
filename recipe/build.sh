#!/bin/bash

# Get an updated config.sub and config.guess
cp -r ${BUILD_PREFIX}/share/libtool/build-aux/config.* ./build-aux

# ./configure --prefix=$PREFIX \
#     --disable-static    \
#     --enable-shared     \
#     --disable-doc       \
#     --disable-silent-rules

./configure \
      --prefix="${PREFIX}" \
      --host="${HOST}" \
      --build="${BUILD}" \
      --disable-static \
      --enable-shared \
      --disable-doc \
      --disable-gtk-doc \
      --disable-gtk-doc-html \
      --disable-gtk-doc-pdf \
      --disable-valgrind-tests \
      --disable-dependency-tracking \
      --disable-silent-rules \
      --enable-year2038

make -j ${CPU_COUNT}

make install

# NOTE: Not the usual way of usual things, but `make install` *must* precede
# `make check`; if it doesn't, fuzzing tests may fail on OS X build systems due
# to libtasn1.dylib not being found in `$PREFIX/lib`.  This is likely due SIP
# breaking the mechanisms libtool uses to set the library search path of the
# test executables; examples of another project running into such issues:
#   - https://dev.gnupg.org/T5159#144621
#   - https://dev.gnupg.org/T5024#139701
make check || \
    { find . -name 'test-*.log' -exec cat {} +; exit 1; }

rm -f ${PREFIX}/share/man/*/asn1* ${PREFIX}/share/info/libtasn1*
