import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as P5Support
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root
    readonly property bool isVertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    property string toolsDir: Qt.resolvedUrl("./tools").toString().substring(7) + "/"
    property string serviceUtil: toolsDir+"service.py"
    property bool enableDebug: plasmoid.configuration.enableDebug
    property string pythonExecutable: plasmoid.configuration.pythonExecutable
    property bool showCoordinates: plasmoid.configuration.showCoordinates
    property int updatesPerSecond: plasmoid.configuration.updatesPerSecond
    property bool onDesktop: plasmoid.location === PlasmaCore.Types.Floating
    property bool cursorPositionCmdRunning: false
    property string serviceCmd: pythonExecutable + " '" + serviceUtil + "'"
    property string serviceRunningCmd: "gdbus call --session --dest luisbocanegra.cursor.eyes --object-path / --method org.freedesktop.DBus.Introspectable.Introspect"
    property string cursorPositionCmd: "gdbus call --session --dest luisbocanegra.cursor.eyes --object-path /cursor --method luisbocanegra.cursor.eyes.get_position"
    property string scriptLoadedCmd: "gdbus call --session --dest org.kde.KWin --object-path /Scripting --method org.kde.kwin.Scripting.isScriptLoaded luisbocanegra.cursor.eyes.kwinscript"
    property string installKwinScriptCmd: "sh " + toolsDir + "kpackage_install_kwinscript.sh '" + toolsDir + "kwin_script/package'"
    property string toggleKWinScriptCmd: "sh " + toolsDir + "toggle_script.sh "
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
    property string eyeColor: plasmoid.configuration.eyeColor
    property string eyeBorderColor: plasmoid.configuration.eyeBorderColor
    property string irisColor: Kirigami.Theme.highlightColor
    property string pupilColor: plasmoid.configuration.pupilColor
    property string themesDir: Qt.resolvedUrl("themes/")
    property int animationDuration: plasmoid.configuration.animationDuration
    property string eyeImage: {
        if (plasmoid.configuration.eyeImage)
            return plasmoid.configuration.eyeImage
        let pixmap = theme["eye-pixmap"]
        if (pixmap !== "") {
            return themesDir + theme["dir"] + "/" + pixmap
        }
        return ""
    }
    property string irisImage: {
        if (plasmoid.configuration.irisImage)
            return plasmoid.configuration.irisImage
        let pixmap = theme["pupil-pixmap"]
        if (pixmap !== "") {
            return themesDir + theme["dir"] + "/" + pixmap
        }
        return ""
    }
    property var theme: {
        var out = {"name":"QML","dir":"","eye-pixmap":"","pupil-pixmap":""}
        try {
            out = JSON.parse(plasmoid.configuration.theme.trim())
        } catch (e) {
            console.error(e, e.stack)
        }
        return out
    }

    Binding {
        target: root
        property: "irisColor"
        value: plasmoid.configuration.irisColor
        when: plasmoid.configuration.irisColor !== ""
    }

    property int cursorGlobalX: -1
    property int cursorGlobalY: -1
    property int cursorGlobalXLast: -1
    property int cursorGlobalYLast: -1
    property var cursorLocalPoint: root.mapFromGlobal(cursorGlobalX, cursorGlobalY)
    property int cursorX: cursorLocalPoint.x
    property int cursorY: cursorLocalPoint.y
    property int cursorAvailable: cursorGlobalX !== -1 && cursorGlobalY !== -1
    property int ready: scriptLoaded && serviceRunning
    property bool idleMode: true
    property real updateInterval: 500
    property real distanceTraveled: 0
    property real maxValue: Number.fromLocaleString(Qt.locale(),"1.7976931348623157e+308")
    property int exceedCount: 0

    property bool wasExpanded
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
            if(cmd === cursorPositionCmd) cursorPositionCmdRunning = true
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

    function getDistance(x1, y1, x2, y2) {
        const dx = x2 - x1
        const dy = y2 - y1
        return Math.sqrt(dx * dx + dy * dy)
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
                let parts = stdout.trim().replace(/[()']/g, "").split(",")
                if (parts.length>1) {
                    const x = parseInt(parts[0])
                    const y = parseInt(parts[1])
                    if (x === -1 && y === -1) return
                    if (x !== cursorGlobalXLast || y !== cursorGlobalYLast) {
                        cursorGlobalXLast = x
                        cursorGlobalYLast = y
                        if ((cursorGlobalX !== -1 && cursorGlobalX !== -1)){
                            let dist = getDistance(x, y, cursorGlobalX, cursorGlobalY)
                            if (distanceTraveled + dist > maxValue) {
                                exceedCount += 1
                                distanceTraveled = 0
                            } else {
                                distanceTraveled += dist
                            }
                        }
                        updateInterval = (1000 / updatesPerSecond)
                        idleMode = false
                        idleTimer.restart()
                    } else {
                        if (idleMode) {
                            updateInterval = 500
                        }
                    }
                    cursorGlobalX = x
                    cursorGlobalY = y
                }
            }
            if(cmd === scriptLoadedCmd) {
                if (stdout.length < 1) return
                stdout = stdout.trim().replace(/[()',]/g, "")
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
        onPressed: wasExpanded = root.expanded
        onClicked: root.expanded = !wasExpanded
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
        id: idleTimer
        interval: 5000
        onTriggered: {
            idleMode = true
        }
    }

    Timer {
        id: cursorCommandTimer
        running: scriptLoaded && serviceRunning
        repeat: true
        interval: updateInterval
        onTriggered: {
            // console.log("Widget updating", interval)
            if (!cursorPositionCmdRunning) runCommand.exec(cursorPositionCmd)
        }
    }

    Component.onCompleted: {
        initTimer.start()
    }
}
