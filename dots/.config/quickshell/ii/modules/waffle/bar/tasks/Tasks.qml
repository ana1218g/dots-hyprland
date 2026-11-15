import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.waffle.looks

MouseArea {
    id: root

    property int dragFrom: -1
    property int dragTarget: -1
    property bool snapping: false
    readonly property int pinnedCount: TaskbarApps.apps.filter(app => app.pinned).length

    Layout.fillHeight: true
    implicitHeight: appRow.implicitHeight
    implicitWidth: appRow.implicitWidth
    hoverEnabled: true

    function showPreviewPopup(appEntry, button) {
        previewPopup.show(appEntry, button);
    }

    Behavior on implicitWidth {
        animation: Looks.transition.move.createObject(this)
    }

    WListView {
        id: appRow
        anchors {
            top: parent.top
            bottom: parent.bottom
        }
        orientation: Qt.Horizontal
        spacing: 0
        implicitWidth: contentWidth
        clip: true
        interactive: false
        // TODO: Include only apps (and windows) in current workspace only | wait, does that even make sense in a Hyprland workflow?
        model: ScriptModel {
            objectProp: "appId"
            values: TaskbarApps.apps.filter(app => app.appId !== "SEPARATOR")
        }        delegate: TaskAppButton {
            required property var modelData
            required property int index
            appEntry: modelData

            shiftAnimated: !root.snapping
            shiftX: {
                if (root.dragFrom < 0 || index === root.dragFrom) return 0;
                if (root.dragFrom < root.dragTarget && index > root.dragFrom && index <= root.dragTarget) return -width;
                if (root.dragFrom > root.dragTarget && index < root.dragFrom && index >= root.dragTarget) return width;
                return 0;
            }

            onDraggingChanged: {
                if (dragging) {
                    root.dragFrom = index;
                    root.dragTarget = index;
                }
            }
            onDragOffsetChanged: {
                if (!dragging) return;
                const t = index + Math.round(dragOffset / width);
                root.dragTarget = Math.max(0, Math.min(root.pinnedCount - 1, t));
            }
            onDragFinished: (offset) => {
                const from = root.dragFrom;
                const to = root.dragTarget;
                root.snapping = true; // ずれを戻すときはアニメーションさせない
                if (from >= 0 && to !== from) TaskbarApps.movePinned(appEntry.appId, to);
                root.dragFrom = -1;
                root.dragTarget = -1;
                root.snapping = false;
            }

            onHoverPreviewRequested: {
                root.showPreviewPopup(appEntry, this);
            }
            onHoverPreviewDismissed: {
                previewPopup.close();
            }
        }
    }

    // Previews popup
    TaskPreview {
        id: previewPopup
        tasksHovered: root.containsMouse
        anchor.window: root.QsWindow.window
    }
}
