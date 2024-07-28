#!/bin/sh

if [ -d "build" ]; then
  rm -rf build
fi

# package plasmoid, skip installing
cmake -B build -S . -DINSTALL_PLASMOID=OFF -DPACKAGE_PLASMOID=ON -DPACKAGE_SCRIPT_QML=ON
cmake --build build
