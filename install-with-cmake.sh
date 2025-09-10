#!/bin/sh

if [ -d "build" ]; then
  rm -rf build
fi

# install plasmoid, skip packaging
cmake -B build -S . -DCMAKE_INSTALL_PREFIX=~/.local

cmake --build build
cmake --install build
