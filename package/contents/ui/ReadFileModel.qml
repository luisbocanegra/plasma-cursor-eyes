import QtQuick
import org.kde.plasma.plasma5support as P5Support

Item {

    id: effectsModel
    property string content: ""
    signal ready(content: string)

    function read(file) {
        if (file.startsWith('file://')) {
            file = file.substring(7)
        }
        runCommand.exec("cat '" + file + "'")
    }

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
            sourceConnected(source)
        }

        function exec(cmd) {
            runCommand.connectSource(cmd)
        }

        signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)
    }

    Connections {
        target: runCommand
        function onExited(cmd, exitCode, exitStatus, stdout, stderr) {
            if (exitCode !== 0 ) return
            if (stdout.length > 0) {
                try {
                    content = stdout.trim()
                    ready(content)
                } catch (e) {
                    console.error(e, e.stack)
                }
            }
        }
    }
}

