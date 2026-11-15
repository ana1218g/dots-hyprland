import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.functions
import qs.modules.waffle.looks

AcrylicButton {
    id: root

    property var altAction: () => {}
    property var middleClickAction: () => {}

    // --- drag support ---
    property bool draggable: false
    property bool dragging: false
    property real dragOffset: 0
    // 他のアイコンがドラッグに押されてずれる量(プレビュー用)
    property real shiftX: 0
    property bool shiftAnimated: true
    signal dragFinished(real offset)

    Behavior on shiftX {
        enabled: root.shiftAnimated
        animation: Looks.transition.move.createObject(this)
    }

    transform: Translate { x: root.dragOffset + root.shiftX }
    z: root.dragging ? 100 : 0

    Layout.fillHeight: true
    topInset: 4
    bottomInset: 4
    leftInset: 0
    rightInset: 0
    horizontalPadding: 8

    colBackground: ColorUtils.transparentize(Looks.colors.bg1)

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        property real pressGX: 0
        property bool wasDragged: false

        // Item自体がTranslateで動くので、ローカル座標ではなくウィンドウ座標で追う
        function globalX(mouse) { return mapToItem(null, mouse.x, 0).x; }

        onPressed: (event) => {
            root.down = true;
            wasDragged = false;
            pressGX = globalX(event);
        }
        onPositionChanged: (event) => {
            if (!root.draggable || !(event.buttons & Qt.LeftButton)) return;
            const delta = globalX(event) - pressGX;
            if (!root.dragging && Math.abs(delta) > 8) root.dragging = true;
            if (root.dragging) root.dragOffset = delta;
        }
        onReleased: (event) => {
            root.down = false;
            if (root.dragging) {
                const offset = root.dragOffset;
                wasDragged = true;
                root.dragging = false;
                root.dragOffset = 0;
                root.dragFinished(offset);
            }
        }
        onClicked: (event) => {
            if (wasDragged) { wasDragged = false; return; } // ドラッグ後のclickは無視
            if (event.button === Qt.LeftButton) root.clicked();
            if (event.button === Qt.RightButton) root.altAction();
            if (event.button === Qt.MiddleButton) root.middleClickAction();
        }

        onCanceled: {
            root.down = false;
            if (root.dragging) {
                root.dragging = false;
                root.dragOffset = 0;
                root.dragFinished(0); // Tasks.qml側のdragFrom/dragTargetも初期化される
            }
        }
    }
}