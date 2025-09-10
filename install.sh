#!/bin/sh

kpackagetool6 --type Plasma/Applet --remove luisbocanegra.cursor.eyes
kpackagetool6 --type Plasma/Applet --install package
kpackagetool6 --type KWin/Script --remove luisbocanegra.cursor.eyes.kwinscript
kpackagetool6 --type KWin/Script --install package/contents/ui/tools/kwin_script/package
