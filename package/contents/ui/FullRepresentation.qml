import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

Item {

    property int preferredTextWidth: Kirigami.Units.gridUnit * 18

    Layout.minimumWidth: mainLayout.implicitWidth + Kirigami.Units.gridUnit
    Layout.minimumHeight: mainLayout.implicitHeight + Kirigami.Units.gridUnit
    Layout.preferredWidth: Layout.minimumWidth
    Layout.preferredHeight: Layout.minimumHeight
    Layout.maximumWidth: Layout.minimumWidth
    Layout.maximumHeight: Layout.minimumHeight

    function truncateString(str, n) {
        if (str.length > n) {
            return str.slice(0, n) + "...";
        } else {
            return str;
        }
    }

    ListModel {
        id: shortcutsList
    }

    ColumnLayout {
        id: mainLayout

        anchors {
            centerIn: parent
        }

        PlasmaComponents.Button {
            text: "Install/Upgrade KWin Script"
            Layout.fillWidth: true
            visible: !(root.scriptLoaded && root.serviceRunning)
            onClicked: {
                runCommand.exec(root.installKwinScriptCmd)
                runCommand.exec(root.toggleKWinScriptCmd + false)
            }
        }
        PlasmaComponents.Button {
            text: "Start/Stop KWin Script"
            Layout.fillWidth: true
            onClicked: {
                runCommand.exec(root.toggleKWinScriptCmd + !root.scriptLoaded)
            }
        }

        GridLayout {
            id: grid
            columns: 2
            rowSpacing: Kirigami.Units.mediumSpacing
            columnSpacing: Kirigami.Units.gridUnit / 2.5
            Layout.preferredWidth: preferredTextWidth
            PlasmaComponents.Label {
                text: "KWin Script running:"
                Layout.alignment: Qt.AlignTop|Qt.AlignRight
            }
            PlasmaComponents.Label {
                text: scriptLoaded
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                wrapMode: Text.Wrap
                color: scriptLoaded
                    ? Kirigami.Theme.positiveTextColor
                    : Kirigami.Theme.negativeTextColor
                font.weight: Font.Bold
            }

            PlasmaComponents.Label {
                text: "D-Bus Service running:"
                Layout.alignment: Qt.AlignTop|Qt.AlignRight
            }
            PlasmaComponents.Label {
                text: serviceRunning
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                wrapMode: Text.Wrap
                color: serviceRunning
                    ? Kirigami.Theme.positiveTextColor
                    : Kirigami.Theme.negativeTextColor
                font.weight: Font.Bold
            }

            PlasmaComponents.Label {
                text: "Cursor position:"
                Layout.alignment: Qt.AlignTop|Qt.AlignRight
            }
            PlasmaComponents.Label {
                text: "X:" + root.cursorGlobalX + " Y:" + root.cursorGlobalY
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                wrapMode: Text.Wrap
                color: root.cursorGlobalX !== -1 && root.cursorGlobalY !== -1
                    ? Kirigami.Theme.textColor
                    : Kirigami.Theme.negativeTextColor
            }

            PlasmaComponents.Label {
                text: "Active window:"
                visible: root.activeWindowResourceName
                Layout.alignment: Qt.AlignTop|Qt.AlignRight
            }

            PlasmaComponents.Label {
                visible: root.activeWindowResourceName
                text: root.activeWindowResourceName
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                wrapMode: Text.Wrap
            }

            PlasmaComponents.Label {
                visible: root.activeWindow.caption && root.activeWindow.caption !== root.activeWindowResourceName
                text: root.activeWindow.caption
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop|Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                Layout.columnSpan: 2
            }

            PlasmaComponents.Label {
                text: "Xwayland:"
                Layout.alignment: Qt.AlignTop|Qt.AlignRight
            }

            PlasmaComponents.Label {
                text: root.activeWindowIsXwayland
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                wrapMode: Text.Wrap
                font.weight: Font.Bold
            }

            PlasmaComponents.Label {
                text: "Xwayland windows:"
                Layout.alignment: Qt.AlignTop|Qt.AlignRight
            }

            PlasmaComponents.Label {
                text: root.xwaylandWindows.join("\n")
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                wrapMode: Text.Wrap
            }

            TextArea {
                text: "'"+serviceError+"'"
                visible: serviceError !== ""
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                Layout.columnSpan: 2
                Layout.preferredWidth: mainLayout.width
                wrapMode: Text.Wrap
                color: Kirigami.Theme.negativeTextColor
                readOnly: true
            }
        }
    }
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            root.expanded = false;
            event.accepted = true;
        }
    }
}
