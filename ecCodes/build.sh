#!/bin/bash

mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_Fortran_COMPILER=$PREFIX/bin/gfortran ../eccodes-2.1.0-Source

make

make install
