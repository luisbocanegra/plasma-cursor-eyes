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

    Layout.minimumWidth: preferredTextWidth
    Layout.minimumHeight: mainLayout.implicitHeight
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
        width: preferredTextWidth

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
