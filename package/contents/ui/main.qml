import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as P5Support

PlasmoidItem {
    id: root
    readonly property bool isVertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    property string toolsDir: Qt.resolvedUrl("./tools").toString().substring(7) + "/"
    property string serviceUtil: toolsDir+"service.py"
    property bool enableDebug: plasmoid.configuration.enableDebug
    property string qdbusExecutable: plasmoid.configuration.qdbusExecutable
    property string pythonExecutable: plasmoid.configuration.pythonExecutable
    property int updatesPerSecond: plasmoid.configuration.updatesPerSecond
    property bool onDesktop: plasmoid.location === PlasmaCore.Types.Floating
    property bool cursorPositionCmdRunning: false
    property string serviceCmd: pythonExecutable + " '" + serviceUtil + "'"
    property string serviceRunningCmd: qdbusExecutable + " luisbocanegra.cursor.eyes / org.freedesktop.DBus.Introspectable.Introspect"
    property string cursorPositionCmd: qdbusExecutable + " luisbocanegra.cursor.eyes /cursor get_position"
    property string scriptLoadedCmd: qdbusExecutable + " org.kde.KWin /Scripting org.kde.kwin.Scripting.isScriptLoaded luisbocanegra.cursor.eyes.kwinscript"
    property bool scriptLoaded: false
    property bool serviceRunning: false
    property string serviceError: ""
    property int eyesCount: plasmoid.configuration.eyesCount
    property int eyeSpacing: plasmoid.configuration.eyeSpacing
    property int eyeBorderWidth: plasmoid.configuration.eyeBorderWidth
    property real eyeScaling: plasmoid.configuration.eyeScaling
    property real irisSize: plasmoid.configuration.irisSize
    property real pupilSize: plasmoid.configuration.pupilSize
    property real fontSize: plasmoid.configuration.fontSize
    property string irisColor: Kirigami.Theme.highlightColor
    property string pupilColor: plasmoid.configuration.pupilColor

    Binding {
        target: root
        property: "irisColor"
        value: plasmoid.configuration.irisColor
        when: plasmoid.configuration.irisColor !== ""
    }

    property int cursorGlobalX: -1
    property int cursorGlobalY: -1
    property var cursorLocalPoint: root.mapFromGlobal(cursorGlobalX, cursorGlobalY)
    property int cursorX: cursorLocalPoint.x
    property int cursorY: cursorLocalPoint.y

    property bool expanded: false
    property bool bgFillPanel: plasmoid.configuration.bgFillPanel
    Plasmoid.constraintHints: bgFillPanel ? Plasmoid.CanFillArea : Plasmoid.NoHint
    preferredRepresentation: compactRepresentation
    compactRepresentation: CompactRepresentation {}
    fullRepresentation: FullRepresentation {}

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
            cursorPositionCmdRunning = true
            runCommand.connectSource(cmd)
        }

        signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)
    }

    P5Support.DataSource {
        id: runService
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
            runService.connectSource(cmd)
        }

        signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)
    }

    Connections {
        target: runService
        function onExited(cmd, exitCode, exitStatus, stdout, stderr) {
            serviceError = (exitCode !== 0) ? stderr.trim() : ""
        }
    }

    Connections {
        target: runCommand
        function onExited(cmd, exitCode, exitStatus, stdout, stderr) {
            cursorPositionCmdRunning = false
            // console.log(cmd);
            // if (exitCode!==0) return
            // console.log(stdout);
            if(cmd === cursorPositionCmd) {
                if (stdout.length < 1) return
                let parts = stdout.trim().split(",")
                if (parts.length>1) {
                    cursorGlobalX = parseInt(parts[0])
                    cursorGlobalY = parseInt(parts[1])
                }
            }
            if(cmd === scriptLoadedCmd) {
                if (stdout.length < 1) return
                stdout = stdout.trim()
                scriptLoaded = stdout === "true"
            }
            if(cmd === serviceRunningCmd) {
                serviceRunning = exitCode === 0
            }
        }
    }

    function printLog(strings, ...values) {
        if (enableDebug) {
            let str = 'CURSOR_EYES_WIDGET: ';
            strings.forEach((string, i) => {
                str += string + (values[i] !== undefined ? values[i] : '');
            });
            console.log(str);
        }
    }

    onCursorXChanged: {
        printLog`Cursor position x:${cursorX} y:${cursorY}`
    }
    onCursorYChanged: {
        printLog`Cursor position x:${cursorX} y:${cursorY}`
    }

    onScriptLoadedChanged: {
        printLog`KWin script loaded: ${scriptLoaded}`
    }

    onServiceRunningChanged: {
        printLog`service running: ${serviceRunning}`
    }

    Rectangle {
        // DEBUG cursor position
        width: 8
        height: 8
        color: "red"
        x: cursorX -4
        y: cursorY -4
        radius: height / 2
        visible: enableDebug
        z:999
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            expanded = !expanded
            // isVertical = !isVertical
        }
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

    Timer {
        id: initTimer
        running: false
        repeat: true
        interval: 1
        onTriggered: {
            runCommand.exec(scriptLoadedCmd)
            runCommand.exec(serviceRunningCmd)
            if ( scriptLoaded && !serviceRunning) {
                printLog`starting service: ${serviceCmd}`
                runService.exec(serviceCmd)
            }
            interval = 1000
        }
    }

    Timer {
        id: runCommandTimer
        running: scriptLoaded && serviceRunning
        repeat: true
        interval: (1000 / updatesPerSecond)
        onTriggered: {
            if (!cursorPositionCmdRunning) runCommand.exec(cursorPositionCmd)
        }
    }

    Component.onCompleted: {
        initTimer.start()
    }
}
