import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import "components" as Components

KCM.SimpleKCM {
    id: root
    property alias cfg_qdbusExecutable: qdbusExecutable.text
    property alias cfg_pythonExecutable: pythonExecutable.text
    property alias cfg_updatesPerSecond: updatesPerSecond.value

    property alias cfg_eyesCount: eyesCountSpinbox.value
    property alias cfg_eyeSpacing: eyeSpacingSpinbox.value
    property alias cfg_eyeBorderWidth: eyeBorderWidthSpinbox.value
    property real cfg_eyeScaling: eyeScalingField.text
    property real cfg_irisSize: irisSizeField.text
    property real cfg_pupilSize: pupilSizeField.text

    property alias cfg_fontSize: fontSizeSpinbox.value
    property alias cfg_bgFillPanel: bgFillPanelCheckbox.checked

    property string cfg_irisColor: irisColorButton.color
    property alias cfg_pupilColor: pupilColorButton.color

    Kirigami.FormLayout {
        id: generalPage
        Layout.alignment: Qt.AlignTop

        TextField {
            Kirigami.FormData.label: i18n("Qdbus 6 executable:")
            id: qdbusExecutable
            placeholderText: qsTr("Qdbus executable e.g. qdbus-qt6, qdbus6")
        }
        TextField {
            Kirigami.FormData.label: i18n("Python 3 executable:")
            id: pythonExecutable
            placeholderText: qsTr("Python executable e.g. python, python3")
        }

        SpinBox {
            Kirigami.FormData.label: i18n("Updates per second:")
            id: updatesPerSecond
            from: 1
            to: 60
        }

        CheckBox {
            Kirigami.FormData.label: i18n("Fill panel:")
            id: bgFillPanelCheckbox
        }

        //// -------------
        SpinBox {
            Kirigami.FormData.label: i18n("Eyes:")
            id: eyesCountSpinbox
            from: 0
            to: 9
        }
        SpinBox {
            Kirigami.FormData.label: i18n("Spacing:")
            id: eyeSpacingSpinbox
            from: 0
            to: 100
        }

        SpinBox {
            Kirigami.FormData.label: i18n("Border width:")
            id: eyeBorderWidthSpinbox
            from: 0
            to: 100
        }


        RowLayout {
            Kirigami.FormData.label: i18n("Eye Scaling:")
            TextField {
                id: eyeScalingField
                placeholderText: "0-1"
                text: parseFloat(cfg_eyeScaling).toFixed(validator.decimals)
                Layout.preferredWidth: Kirigami.Units.gridUnit * 4.5

                validator: DoubleValidator {
                    bottom: 0.0
                    top: 1.0
                    decimals: 2
                    notation: DoubleValidator.StandardNotation
                }

                onTextChanged: {
                    const newVal = parseFloat(text)
                    cfg_eyeScaling = isNaN(newVal) ? 0 : newVal
                }

                Components.ValueMouseControl {
                    height: parent.height - 8
                    width: height
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    anchors.verticalCenter: parent.verticalCenter

                    from: parent.validator.bottom
                    to: parent.validator.top
                    decimals: parent.validator.decimals
                    stepSize: 0.05
                    value: cfg_eyeScaling
                    onValueChanged: {
                        cfg_eyeScaling = parseFloat(value)
                    }
                }
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Iris Scaling:")
            TextField {
                id: irisSizeField
                placeholderText: "0-1"
                text: parseFloat(cfg_irisSize).toFixed(validator.decimals)
                Layout.preferredWidth: Kirigami.Units.gridUnit * 4.5

                validator: DoubleValidator {
                    bottom: 0.0
                    top: 1.0
                    decimals: 2
                    notation: DoubleValidator.StandardNotation
                }

                onTextChanged: {
                    const newVal = parseFloat(text)
                    cfg_irisSize = isNaN(newVal) ? 0 : newVal
                }

                Components.ValueMouseControl {
                    height: parent.height - 8
                    width: height
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    anchors.verticalCenter: parent.verticalCenter

                    from: parent.validator.bottom
                    to: parent.validator.top
                    decimals: parent.validator.decimals
                    stepSize: 0.05
                    value: cfg_irisSize
                    onValueChanged: {
                        cfg_irisSize = parseFloat(value)
                    }
                }
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Pupil Scaling:")
            TextField {
                id: pupilSizeField
                placeholderText: "0-1"
                text: parseFloat(cfg_pupilSize).toFixed(validator.decimals)
                Layout.preferredWidth: Kirigami.Units.gridUnit * 4.5

                validator: DoubleValidator {
                    bottom: 0.0
                    top: 1.0
                    decimals: 2
                    notation: DoubleValidator.StandardNotation
                }

                onTextChanged: {
                    const newVal = parseFloat(text)
                    cfg_pupilSize = isNaN(newVal) ? 0 : newVal
                }

                Components.ValueMouseControl {
                    height: parent.height - 8
                    width: height
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    anchors.verticalCenter: parent.verticalCenter

                    from: parent.validator.bottom
                    to: parent.validator.top
                    decimals: parent.validator.decimals
                    stepSize: 0.05
                    value: cfg_pupilSize
                    onValueChanged: {
                        cfg_pupilSize = parseFloat(value)
                    }
                }
            }
        }

        SpinBox {
            Kirigami.FormData.label: i18n("Text size:")
            id: fontSizeSpinbox
            from: 0
            to: 100
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Iris color:")
            Components.ColorButton {
                id: irisColorButton
                showAlphaChannel: false
                dialogTitle: i18n("Iris color")
                color: cfg_irisColor !== "" ? cfg_irisColor : Kirigami.Theme.highlightColor
                onAccepted: {
                    cfg_irisColor = color
                }
            }
            Button {
                icon.name: "edit-undo-symbolic"
                flat: true
                onClicked: {
                    cfg_irisColor = ""
                    irisColorButton.color = Kirigami.Theme.highlightColor
                }
                ToolTip.text: i18n("Reset to default")
                ToolTip.visible: hovered
                enabled: cfg_irisColor !== ""
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Iris color:")
            Components.ColorButton {
                id: pupilColorButton
                showAlphaChannel: false
                dialogTitle: i18n("Iris color")
                color: cfg_pupilColor
                onAccepted: {
                    cfg_pupilColor = color
                }
            }
            Button {
                icon.name: "edit-undo-symbolic"
                flat: true
                onClicked: {
                    // pupilColorButton.color = "#222222"
                    cfg_pupilColor = "#222222"
                }
                ToolTip.text: i18n("Reset to default")
                ToolTip.visible: hovered
                enabled: cfg_pupilColor !== "#222222"
            }
        }

    }
}

