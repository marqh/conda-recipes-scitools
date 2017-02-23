#!/bin/bash

mkdir build_gfortran
cd build_gfortran

ln -s "$PREFIX/lib" "$PREFIX/lib64"

if [ "$(uname)" == "Darwin" ]; then
    # On Mac, we expect that the user has installed the xcode command-line utilities (via the 'xcode-select' command).
    # The system's libstdc++.6.dylib will be located in /usr/lib, and we need to help the gcc build find it.
    export LDFLAGS="-Wl,-headerpad_max_install_names -Wl,-L${PREFIX}/lib -Wl,-L/usr/lib"
    export DYLD_FALLBACK_LIBRARY_PATH="$PREFIX/lib:/usr/lib"

    configure \
        --prefix="$PREFIX" \
        --with-gxx-include-dir="$PREFIX/include/c++" \
        --bindir="$PREFIX/bin" \
        --datarootdir="$PREFIX/share" \
        --libdir="$PREFIX/lib" \
        --with-gmp="$PREFIX" \
        --with-mpfr="$PREFIX" \
        --with-mpc="$PREFIX" \
        --with-isl="$PREFIX" \
        --with-cloog="$PREFIX" \
        --with-boot-ldflags="$LDFLAGS" \
        --with-stage1-ldflags="$LDFLAGS" \
        --with-tune=generic \
        --disable-multilib \
        --enable-checking=release \
        --with-build-config=bootstrap-debug \
        --enable-languages=c,fortran
else
    # For reference during post-link.sh, record some
    # details about the OS this binary was produced with.
    mkdir -p "${PREFIX}/share"
    cat /etc/*-release > "${PREFIX}/share/conda-gcc-build-machine-os-details"
    export CFLAGS="-I${PREFIX}/include"
    export CXXFLAGS="-I${PREFIX}/include"
    export CPPFLAGS="-I${PREFIX}/include"
    export LDFLAGS="-L${PREFIX}/lib"
    configure \
        --prefix="$PREFIX" \
        --with-gxx-include-dir="$PREFIX/include/c++" \
        --bindir="$PREFIX/bin" \
        --datarootdir="$PREFIX/share" \
        --libdir="$PREFIX"/lib \
        --with-mpfr="$PREFIX" \
        --with-isl="$PREFIX" \
        --with-cloog="$PREFIX" \
        --enable-checking=release \
        --with-tune=generic \
        --disable-multilib \
        --enable-languages=c,fortran
fi
make -j"$CPU_COUNT"
make install-strip
