/*
    SPDX-FileCopyrightText: 2014 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as P5Support

PlasmoidItem {
    id: root
    property bool horizontal: Plasmoid.formFactor !== PlasmaCore.Types.Vertical
    property string toolsDir: Qt.resolvedUrl("./tools").toString().substring(7) + "/"
    property string serviceUtil: toolsDir+"service.py"
    property bool enableDebug: plasmoid.configuration.enableDebug
    property string qdbusExecutable: plasmoid.configuration.qdbusExecutable
    property bool onDesktop: plasmoid.location === PlasmaCore.Types.Floating
    property bool bgFillPanel: plasmoid.configuration.bgFillPanel
    Plasmoid.constraintHints: bgFillPanel ? Plasmoid.CanFillArea : Plasmoid.NoHint

    function getServiceCommand(scriptName) {
        const scriptFile = toolsDir + scriptName + ".js"
        return "python3 '" + serviceUtil + "' '" + scriptName + "' '" + scriptFile + "' '" + qdbusExecutable + "'"
    }

    Layout.minimumWidth: onDesktop
        ? content.implicitWidth
        : horizontal ? parent.height : parent.width
    Layout.minimumHeight: Layout.minimumWidth
    Layout.preferredWidth: onDesktop
        ? content.implicitWidth
        : horizontal ? content.implicitWidth : parent.height
    Layout.preferredHeight: onDesktop
        ? content.implicitHeight
        : horizontal ? content.implicitHeight : parent.width

    preferredRepresentation: fullRepresentation

    property var cursorPositionCmd: qdbusExecutable + " luisbocanegra.cursor.eyes /cursor get_position"
    property string serviceCmd: getServiceCommand("getCursorPosition")
    property var cursorX: -1
    property var cursorY: -1

    P5Support.DataSource {
        id: runCommand
        engine: "executable"
        connectedSources: []

        onNewData: function (source, data) {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            exited(source, exitCode, exitStatus, stdout, stderr)
            disconnectSource(source)
        }

        function exec(cmd) {
            runCommand.connectSource(cmd)
        }

        signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)
    }

    P5Support.DataSource {
        id: runCommand2
        engine: "executable"
        connectedSources: []

        onNewData: function (source, data) {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            exited(source, exitCode, exitStatus, stdout, stderr)
            disconnectSource(source)
        }

        function exec(cmd) {
            runCommand.connectSource(cmd)
        }

        signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)
    }

    Connections {
        target: runCommand
        function onExited(cmd, exitCode, exitStatus, stdout, stderr) {
            // console.log(cmd);
            if (exitCode!==0) return
            // console.log(stdout);
            if(cmd === cursorPositionCmd) {
                if (stdout.length < 1) return
                let parts = stdout.trim().split(",")
                if (parts.length>1) {
                    cursorX = parts[0]
                    cursorY = parts[1]
                }
            }
        }
    }

    function printLog(strings, ...values) {
        if (enableDebug) {
            let str = 'PLASMOID_EYES: ';
            strings.forEach((string, i) => {
                str += string + (values[i] !== undefined ? values[i] : '');
            });
            console.log(str);
        }
    }

    // Rectangle {
    //     id: dragArea
    //     anchors.fill: parent
    //     opacity: 0.3
    //     color: "red"
    // }

    property Component eyeComponent: Rectangle {
        property int offset: 0
        id: eye
        width: 22
        height: width
        radius: width / 2
        color: "transparent"
        border.width: 2
        border.color: Kirigami.Theme.textColor

        property real posX: 0
        property real posY: 0

        Timer {
            running: true
            repeat: true
            interval: 500
            onTriggered: {
                eye.posX = eye.mapToGlobal(eye.x, eye.y).x + (horizontal ? offset : 0)
                eye.posY = eye.mapToGlobal(eye.x, eye.y).y + (!horizontal ? offset : 0)
            }
        }

        function calculateIrisPosition(mouseX, mouseY, eyeX, eyeY) {
            var dx = mouseX - eyeX - eye.width / 2;
            var dy = mouseY - eyeY - eye.height / 2;
            var distance = Math.sqrt(dx * dx + dy * dy);
            var maxDistance = (iris.width/2) - 2;
            if (distance > maxDistance) {
                dx *= maxDistance / distance;
                dy *= maxDistance / distance;
            }
            const x = dx + eye.width / 2 - iris.width / 2;
            const y = dy + eye.height / 2 - iris.height / 2;
            return [x,y]
        }

        Rectangle {
            id: iris
            width: eye.width / 2;
            height: width
            radius: width / 2
            color: Kirigami.Theme.highlightColor
            property var ps: eye.calculateIrisPosition(root.cursorX, root.cursorY, eye.posX, eye.posY)
            x: ps[0]
            y: ps[1]

            Behavior on x {
                NumberAnimation {
                    duration: 50
                }
            }
            Behavior on y {
                NumberAnimation {
                    duration: 50
                }
            }
        }
    }

    RowLayout {
        id: content
        anchors.centerIn: parent
        Component.onCompleted: {
            eyeComponent.createObject(content, { "offset": 0 })
            eyeComponent.createObject(content, { "offset": -22 - content.spacing })
        }
    }

    function getDragDirection(startPoint, endPoint) {
        var dx = endPoint.x - startPoint.x;
        var dy = endPoint.y - startPoint.y;
        if (Math.abs(dx) > Math.abs(dy)) {
            return dx > 0 ? 'right' : 'left';
        } else {
            return dy > 0 ? 'down' : 'up';
        }
    }

    function getDistance(startPoint, endPoint) {
        var dx = endPoint.x - startPoint.x;
        var dy = endPoint.y - startPoint.y;
        return Math.sqrt(dx * dx + dy * dy)
    }

    function dumpProps(obj) {
        console.error("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        for (var k of Object.keys(obj)) {
            const val = obj[k]
            // if (typeof val === 'function') continue
            if (k === 'metaData') continue
            print(k + "=" + val+"\n")
        }
    }

    // Timer {
    //     id: debugTimer
    //     running: true
    //     repeat: true
    //     interval: 1000
    //     onTriggered: {
    //         if (enableDebug) {
    //             dumpProps(root)
    //         }
    //     }
    // }


    Timer {
        id: getPositionTimer
        running: false
        repeat: true
        interval: 16
        onTriggered: {
            runCommand.exec(cursorPositionCmd)
        }
    }

    Component.onCompleted: {
        runCommand2.exec(serviceCmd)
        getPositionTimer.start()
    }

    function stopTasks() {
        runCommand2.exec("true")
        runCommand.exec("true")
        getPositionTimer.stop()
    }

    Connections {
        target: Qt.application
        function onAboutToQuit() {
            stopTasks()
        }
    }

    Component.onDestruction: {
        stopTasks()
    }
}
