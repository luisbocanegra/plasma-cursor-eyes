/*
  KWin script to send cursor to Cursor Eyes widget (QML version)
  https://github.com/luisbocanegra/plasma-cursor-eyes
 */

import QtQuick
import QtQuick.Window
import org.kde.kirigami as Kirigami
import org.kde.kwin

Item {
    id: root
    property string serviceName: "luisbocanegra.cursor.eyes"
    property string path: "/cursor"
    property var cursorPosLast: { "x": -1, "y": -1 }

    DBusCall {
        id: dbus
        service: "luisbocanegra.cursor.eyes"
        dbusInterface: "luisbocanegra.cursor.eyes"
        path: "/cursor"
        method: "save_position"
        Component.onCompleted: dbus.call()
    }

    Timer {
        id: debugTimer
        running: true
        repeat: true
        interval: 16
        onTriggered: {
            // console.log("updating")
            const cursorPos = Workspace.cursorPos
            if (cursorPos.x !== cursorPosLast.x || cursorPos.y !== cursorPosLast.y) {
                cursorPosLast = { "x": cursorPos.x, "y": cursorPos.y }
                const position_str = cursorPos.x + "," + cursorPos.y
                // console.log("changed", position_str)
                dbus.arguments = [cursorPos.x + "," + cursorPos.y]
                dbus.call()
            }
        }
    }
}
