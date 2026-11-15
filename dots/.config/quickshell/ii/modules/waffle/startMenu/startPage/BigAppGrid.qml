pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.modules.waffle.looks

GridLayout {
    id: root

    property list<var> desktopEntries: []

    property int dragFrom: -1
    property int dragTarget: -1
    property bool snapping: false

    columnSpacing: 0
    rowSpacing: 0

    uniformCellHeights: true
    uniformCellWidths: true

    // (cx, cy) にあるセルの番号。どこにも無ければ -1
    function cellAt(cx, cy) {
        for (let i = 0; i < repeater.count; i++) {
            const it = repeater.itemAt(i);
            if (it && cx >= it.x && cx < it.x + it.width && cy >= it.y && cy < it.y + it.height) return i;
        }
        return -1;
    }

    // ドラッグ中、i番のアイコンが見かけ上入るスロット
    function slotOf(i) {
        if (dragFrom < 0 || i === dragFrom) return i;
        if (dragFrom < dragTarget && i > dragFrom && i <= dragTarget) return i - 1;
        if (dragFrom > dragTarget && i < dragFrom && i >= dragTarget) return i + 1;
        return i;
    }

    Repeater {
        id: repeater
        model: root.desktopEntries
        delegate: StartAppButton {
            id: pinnedAppButton
            required property var modelData
            required property int index
            desktopEntry: modelData
            draggable: true

            shiftAnimated: !root.snapping
            shiftX: {
                const s = root.slotOf(index);
                if (s === index) return 0;
                const target = repeater.itemAt(s);
                return target ? target.x - x : 0;
            }
            shiftY: {
                const s = root.slotOf(index);
                if (s === index) return 0;
                const target = repeater.itemAt(s);
                return target ? target.y - y : 0;
            }

            onClicked: {
                GlobalStates.searchOpen = false;
                desktopEntry.execute();
            }
            onDragStarted: {
                root.dragFrom = index;
                root.dragTarget = index;
            }
            onDragMoved: (cx, cy) => {
                const t = root.cellAt(cx, cy);
                if (t >= 0) root.dragTarget = t; // セルの外では直前の位置を維持
            }
            onDragReleased: {
                const id = desktopEntry.id;
                const from = root.dragFrom;
                const to = root.dragTarget;
                root.snapping = true; // ずれを戻すときはアニメーションさせない
                if (from >= 0 && to !== from) LauncherApps.movePinned(id, to);
                root.dragFrom = -1;
                root.dragTarget = -1;
                root.snapping = false;
            }
        }
    }
}