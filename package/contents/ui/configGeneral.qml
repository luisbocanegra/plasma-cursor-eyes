import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: root
    property alias cfg_qdbusExecutable: qdbusExecutable.text
    property alias cfg_pythonExecutable: pythonExecutable.text
    property alias cfg_updatesPerSecond: updatesPerSecond.value

    Kirigami.FormLayout {
        id: generalPage
        Layout.alignment: Qt.AlignTop

        TextField {
            Kirigami.FormData.label: i18n("Qdbus 6 executable:")
            id: qdbusExecutable
            placeholderText: qsTr("Custom qdbus command e.g. qdbus-qt6, qdbus6")
        }
        TextField {
            Kirigami.FormData.label: i18n("Python 3 executable:")
            id: pythonExecutable
            placeholderText: qsTr("Custom qdbus command e.g. python, python3")
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Updates per second:")
            SpinBox {
                id: updatesPerSecond
                from: 1
                to: 60
            }
        }
    }
}

