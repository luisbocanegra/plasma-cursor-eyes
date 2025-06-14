pragma ComponentBehavior: Bound
pragma ValueTypeBehavior: Addressable

import QtQuick

Item {
    id: root
    property string busType
    property string service: ""
    property string objectPath: ""
    property string iface: ""
    property string method: ""
    property var arguments: []
    property var signature: null
    property var inSignature: null
    signal callFinished(reply: var)

    property var msg: {
        "service": root.service,
        "path": root.objectPath,
        "iface": root.iface,
        "member": root.method,
        "arguments": root.arguments,
        "signature": root.signature,
        "inSignature": root.inSignature
    }

    function builCmd() {
        let cmd = "gdbus call --session --dest " + service + " --object-path " + objectPath + " --method " + (iface || service) + "." + method;
        if (root.arguments.length !== 0) {
            cmd += ` '${root.arguments.join(" ")}'`;
        }
        return cmd;
    }

    RunCommand {
        id: runCommand
        onExited: (cmd, exitCode, exitStatus, stdout, stderr) => {
            if (exitCode !== 0) {
                root.callFinished({
                    isError: true,
                    isValid: false,
                    error: {
                        isValid: false,
                        message: stderr
                    },
                    value: stderr
                });
            } else {
                stdout = stdout.trim().replace(/^\([']?/, "") // starting ( or ('
                .replace(/[']?,\)$/, ""); // ending ,) or ',)
                root.callFinished({
                    isError: false,
                    isValid: true,
                    error: {
                        isValid: false,
                        message: ""
                    },
                    value: stdout
                });
            }
        }
    }

    property var callbackRef: null

    function call(callback) {
        if (callbackRef) {
            callFinished.disconnect(callbackRef);
        }
        callbackRef = callback;
        callFinished.connect(callback);
        runCommand.run(builCmd());
    }
}
