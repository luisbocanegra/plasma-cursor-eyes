import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: root
    property alias cfg_enableDebug: enableDebug.checked

    Kirigami.FormLayout {
        id: generalPage
        Layout.alignment: Qt.AlignTop

        ColumnLayout {
            CheckBox {
                id: enableDebug
                text: "Log debug messages"
                checked: cfg_enableDebug

                onCheckedChanged: {
                    cfg_enableDebug = checked
                }
            }
        }
    }
}

