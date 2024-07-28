#!/bin/sh

SCRIPT_DIR=$1

kpackagetool6 --type KWin/Script --install "$SCRIPT_DIR"
kpackagetool6 --type KWin/Script --upgrade "$SCRIPT_DIR"
