import QtQuick
import org.kde.plasma.plasma5support as P5Support

Item {
    id: root
    property string content: ""
    signal ready(content: string)

    onReady: content => {
        root.content = content;
    }

    function read(file) {
        if (file.startsWith('file://')) {
            file = file.substring(7);
        }
        runCommand.run("cat '" + file + "'");
    }

    RunCommand {
        id: runCommand
        onExited: (cmd, exitCode, exitStatus, stdout, stderr) => {
            if (exitCode !== 0)
                return;
            if (stdout.length > 0) {
                try {
                    root.ready(stdout.trim());
                } catch (e) {
                    console.error(e, e.stack);
                }
            }
        }
    }
}
