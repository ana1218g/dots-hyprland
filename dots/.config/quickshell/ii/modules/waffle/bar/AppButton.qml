import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import org.kde.kirigami as Kirigami
import qs.services
import qs.modules.common
import qs.modules.waffle.looks

BarButton {
    id: root

    required property string iconName
    property bool multiple: false
    property bool separateLightDark: false
    property alias tryCustomIcon: iconWidget.tryCustomIcon
    leftInset: 2
    rightInset: 2
    implicitWidth: height - topInset - bottomInset + leftInset + rightInset

    property real pressedScale: 5/6

    onDownChanged: {
        function updateScale() {
            const active = root.down || root.dragging;
            scaleAnim.duration = active ? 150 : 200
            scaleAnim.easing.bezierCurve = active ? Looks.transition.easing.bezierCurve.easeIn : Looks.transition.easing.bezierCurve.easeOut
            contentItem.scale = root.dragging ? 1.25 : (root.down ? root.pressedScale : 1)
        }
        onDownChanged: updateScale()
        onDraggingChanged: updateScale()
    }

    background: Item {
        id: background
        BackgroundAcrylicRectangle {
            id: mainBgRect
            anchors.fill: parent
            layer.enabled: root.multiple
            layer.effect: OpacityMask {
                invert: true
                maskSource: Item {
                    width: mainBgRect.width
                    height: mainBgRect.height
                    Rectangle {
                        anchors.fill: parent
                        anchors.rightMargin: 3
                        radius: mainBgRect.radius
                    }
                }
            }
        }
        Loader {
            anchors.fill: parent
            anchors.rightMargin: 5
            active: root.multiple
            sourceComponent: BackgroundAcrylicRectangle {}
        }
    }

    contentItem: Item {
        id: contentItem
        anchors.centerIn: root.background

        implicitHeight: iconWidget.implicitHeight
        implicitWidth: iconWidget.implicitWidth

        scale: root.dragging ? 1.25 : (root.down ? root.pressedScale : 1)
        Behavior on scale {
            NumberAnimation {
                duration: (root.down || root.dragging) ? 150 : 200
                easing.type: Easing.BezierSpline
                easing.bezierCurve: (root.down || root.dragging)
                    ? Looks.transition.easing.bezierCurve.easeIn
                    : Looks.transition.easing.bezierCurve.easeOut
            }
        }

        WAppIcon {
            id: iconWidget
            anchors.centerIn: parent
            iconName: root.iconName
            separateLightDark: root.separateLightDark
        }
    }

    component BackgroundAcrylicRectangle: AcrylicRectangle {
        shiny: ((root.hovered && !root.down) || root.checked)
        color: root.color
        border.width: 1
        border.color: root.colBackgroundBorder

        Behavior on border.color {
            animation: Looks.transition.color.createObject(this)
        }
    }
}
