import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3

Item {
    id: compact
    Layout.minimumWidth: root.isVertical ? Kirigami.Units.iconSizes.small : (grid.width)
    Layout.minimumHeight: root.isVertical ? (grid.height) : Kirigami.Units.iconSizes.small
    Layout.preferredWidth: Layout.minimumWidth
    Layout.preferredHeight: Layout.minimumHeight
    readonly property real containerSize: root.isVertical ? parent.width : parent.height
    readonly property real buttonSize: Kirigami.Units.iconSizes.roundedIconSize(root.isVertical ? parent.width : parent.height) * root.eyeScaling

    property Component eyeComponent: Rectangle {
        id: eye
        width: compact.buttonSize
        height: width
        radius: width / 2
        property int index: 0
        property real offsetX: root.isVertical ? (containerSize - buttonSize) / 2 : (eye.width + root.eyeSpacing ) * index + 0
        property real offsetY: root.isVertical ? (eye.width + root.eyeSpacing ) * index + 0 : (containerSize - buttonSize) / 2
        property real centerX: (eye.x + iris.width) + offsetX
        property real centerY: (eye.y + iris.width) + offsetY
        property int borderWidth: root.eyeBorderWidth
        property real angleDeg: Math.atan2(root.cursorY - centerY , root.cursorX - centerX ) * 180 / Math.PI;
        border.width: borderWidth
        border.color: Kirigami.Theme.textColor
        color: "transparent"

        Rectangle {
            // DEBUG
            anchors.fill: parent
            color: "transparent"
            border.width: 1
            border.color: "red"
            visible: root.enableDebug
        }

        function calculateIrisPosition(mouseX, mouseY, eyeX, eyeY) {
            var dx = mouseX - eyeX - eye.width / 2;
            var dy = mouseY - eyeY - eye.height / 2;
            var distance = Math.sqrt(dx * dx + dy * dy);
            var maxDistance = (eye.width - iris.width) / 2 - eye.borderWidth
            if (distance > maxDistance) {
                dx *= maxDistance / distance;
                dy *= maxDistance / distance;
            }
            const x = dx + eye.width / 2 - iris.width / 2;
            const y = dy + eye.height / 2 - iris.height / 2;
            return [x,y]
        }

        Rectangle {
            id: iris
            width: eye.width * root.irisSize
            height: width
            radius: width / 2
            color: Kirigami.Theme.highlightColor
            
            Rectangle {
                id: pupil
                anchors.centerIn: parent
                width: iris.width * root.pupilSize
                height: width
                radius: width / 2
                color: Kirigami.Theme.backgroundColor
            }

            visible: root.scriptLoaded && root.serviceRunning

            property var ps: eye.calculateIrisPosition(root.cursorX, root.cursorY, eye.x + offsetX, eye.y + offsetY)
            x: ps[0]
            y: ps[1]

            Behavior on x {
                NumberAnimation {
                    duration: 50
                }
            }
            Behavior on y {
                NumberAnimation {
                    duration: 50
                }
            }

            Rectangle {
                // DEBUG
                anchors.fill: parent
                color: "transparent"
                border.width: 1
                border.color: "red"
                visible: root.enableDebug
            }
        }

        Rectangle {
            // DEBUG center of eye
            width: 4
            height: 4
            color: "white"
            anchors.centerIn: parent
            visible: root.enableDebug
        }

        Rectangle {
            // DEBUG line that points to cursor
            id: pointerRect
            height: 2
            width: parent.height
            color: "red"
            anchors.centerIn: parent
            visible: root.enableDebug
            transform: [
                Rotation {
                    origin.x: 0
                    origin.y: pointerRect.height / 2
                    angle: Math.round(angleDeg);
                },
                Translate { x: eye.width / 2 }
            ]
        }

        PlasmaComponents3.Label {
            text: "?"
            font.weight: Font.Bold
            visible: !iris.visible
            anchors.centerIn: parent
            font.pointSize: iris.width - (root.borderWidth / 2)
        }
    }

    GridLayout {
        id: grid
        columns: root.isVertical ? 1 : 2
        rows: root.isVertical ? 2 : 1
        width: root.isVertical ? compact.buttonSize : implicitWidth
        height: root.isVertical ? implicitHeight : compact.buttonSize
        anchors.centerIn: parent
        GridLayout {
            columns: root.isVertical ? 1 : root.eyesCount
            rows: root.isVertical ? root.eyesCount : 1
            width: parent.width
            height: parent.height
            columnSpacing: root.isVertical ? 0 : root.eyeSpacing
            rowSpacing: root.isVertical ? root.eyeSpacing : 0
            Layout.alignment: Layout.AlignVCenter
            Repeater {
                model: root.eyesCount
                Rectangle {
                    Layout.preferredWidth: compact.buttonSize
                    Layout.preferredHeight: compact.buttonSize
                    border.width: 1
                    border.color: root.enableDebug ? "red" : "transparent"
                    color: root.enableDebug ? "#3fff0000" : "transparent"
                    Component.onCompleted: {
                        console.log(index);
                        eyeComponent.createObject(this, {"index": index})
                    }
                }
            }
        }
        ColumnLayout {
            spacing: 0
            PlasmaComponents3.Label {
                text: "X:" + root.cursorGlobalX
                font.pointSize: root.fontSize
                font.family: "Monospace"
                fontSizeMode: Text.Fit
                Rectangle {
                    anchors.fill: parent
                    border.color: "blue"
                    border.width: 1
                    color: "transparent"
                    visible: root.enableDebug
                }
            }
            PlasmaComponents3.Label {
                text: "Y:" + root.cursorGlobalY
                font.pointSize: root.fontSize
                font.family: "Monospace"
                fontSizeMode: Text.Fit
                Rectangle {
                    anchors.fill: parent
                    border.color: "blue"
                    border.width: 1
                    color: "transparent"
                    visible: root.enableDebug
                }
            }
        }
    }
}
