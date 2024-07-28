#!/usr/bin/env bash

SCRIPT_NAME="luisbocanegra.cursor.eyes.kwinscriptEnabled"
ENABLED=$1

kwriteconfig6 --file kwinrc --group Plugins --key $SCRIPT_NAME "$ENABLED"

gdbus call --session --dest org.kde.KWin --object-path /KWin --method org.kde.KWin.reconfigure >/dev/null
