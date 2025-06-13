/*
  KWin script to send cursor to Cursor Eyes widget (QML version)
  https://github.com/luisbocanegra/plasma-cursor-eyes
 */

import QtQuick
import org.kde.kwin

Item {
    id: root
    property string serviceName: "luisbocanegra.cursor.eyes"
    property string path: "/cursor"
    property string method: "save_position"
    property var cursorPosLast: {
        "x": -1,
        "y": -1
    }
    property int updatesPerSecond: KWin.readConfig("UpdatesPerSecond", 30)
    property real reloadIntervalMs: 1000 / updatesPerSecond
    property bool enableDebug: KWin.readConfig("EnableDebug", false)
    property bool idleMode: true

    Component.onCompleted: {
        printLog`Updates per second: ${updatesPerSecond} interval: ${reloadIntervalMs.toFixed(2)}`;
    }

    DBusCall {
        id: dbus
        service: serviceName
        dbusInterface: serviceName
        path: root.path
        method: root.method
        Component.onCompleted: dbus.call()
    }
    function dumpProps(obj) {
        console.error("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        for (var k of Object.keys(obj)) {
            const val = obj[k];
            // if (typeof val === 'function') continue
            if (k === 'metaData')
                continue;
            print(k + "=" + val + "\n");
        }
    }

    function printLog(strings, ...values) {
        if (enableDebug) {
            let str = 'CURSOR_EYES_QML_SCRIPT: ';
            strings.forEach((string, i) => {
                str += string + (values[i] !== undefined ? values[i] : '');
            });
            console.log(str);
        }
    }

    Timer {
        id: idleTimer
        interval: 5000
        onTriggered: {
            idleMode = true;
        }
    }

    Timer {
        running: true
        repeat: true
        interval: 500
        onTriggered: {
            // console.log("KWIN updating", interval)
            const cursorPos = Workspace.cursorPos;
            if (cursorPos.x !== cursorPosLast.x || cursorPos.y !== cursorPosLast.y) {
                cursorPosLast = {
                    "x": cursorPos.x,
                    "y": cursorPos.y
                };
                printLog`Cursor position changed x:${cursorPos.x} y:${cursorPos.y}`;
                interval = reloadIntervalMs;
                idleMode = false;
                idleTimer.restart();
                dbus.arguments = [cursorPos.x + "," + cursorPos.y];
                dbus.call();
            } else {
                if (idleMode) {
                    interval = 500;
                }
            }
        }
    }
}
