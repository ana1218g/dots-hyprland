import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.waffle.looks

Item {
    id: root

    // ---- 好みで変えるところ ----
    property bool showNumbers: false   // true: 空のワークスペースを常に数字にする / false: 点
    readonly property real cellSize: 24
    readonly property real iconSize: 18
    readonly property real padding: 3
    // ---------------------------

    readonly property int shownCount: 10
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.QsWindow.window?.screen)
    readonly property int activeWorkspace: monitor?.activeWorkspace?.id ?? 1
    readonly property int group: Math.max(0, Math.floor((activeWorkspace - 1) / shownCount))
    readonly property int activeIndex: Math.max(0, Math.min(shownCount - 1, activeWorkspace - 1 - group * shownCount))

    // Superキー長押し中
    property bool superHeld: false
    readonly property real shrunkIconSize: cellSize * 0.5

    Timer {
        id: superTimer
        interval: Config.options.bar.workspaces.showNumberDelay
        repeat: false
        onTriggered: root.superHeld = true
    }
    Connections {
        target: GlobalStates
        function onSuperDownChanged() {
            if (GlobalStates.superDown) {
                superTimer.restart();
            } else {
                superTimer.stop();
                root.superHeld = false;
            }
        }
        function onSuperReleaseMightTriggerChanged() {
            superTimer.stop();
        }
    }

    // そのワークスペースで最後にフォーカスされたウィンドウ(1つならそれ)
    function mainWindowFor(wsId) {
        let best = null;
        for (const w of HyprlandData.windowList) {
            if (w.workspace?.id !== wsId || w.mapped === false) continue;
            if (!best || (w.focusHistoryID ?? 9999) < (best.focusHistoryID ?? 9999)) best = w;
        }
        return best;
    }

    function occupiedAt(index) {
        return !!mainWindowFor(group * shownCount + index + 1);
    }

    // index がウィンドウありの連続区間の先頭なら、その長さ。それ以外は 0
    function runLengthFrom(index) {
        if (!occupiedAt(index) || (index > 0 && occupiedAt(index - 1))) return 0;
        let n = 1;
        while (index + n < shownCount && occupiedAt(index + n)) n++;
        return n;
    }

    Layout.fillHeight: true
    Layout.leftMargin: 4
    Layout.rightMargin: 6
    implicitWidth: area.width + root.padding * 2
    implicitHeight: 48

    // 外側のカプセル
    Rectangle {
        anchors.centerIn: parent
        width: area.width + root.padding * 2
        height: root.cellSize + root.padding * 2
        radius: height / 2
        color: Looks.colors.bg1
        border.width: 1
        border.color: Looks.colors.bg0Border
    }

    Item {
        id: area
        anchors.centerIn: parent
        width: root.shownCount * root.cellSize
        height: root.cellSize

        // ウィンドウがあるワークスペースの連続区間(つながったカプセル)
        Repeater {
            model: root.shownCount
            delegate: Rectangle {
                required property int index
                readonly property int run: root.runLengthFrom(index)
                x: index * root.cellSize
                width: run * root.cellSize
                height: root.cellSize
                radius: height / 2
                color: ColorUtils.transparentize(Looks.colors.accent, 0.75)
                opacity: run > 0 ? 1 : 0

                Behavior on width {
                    animation: Looks.transition.move.createObject(this)
                }
                Behavior on opacity {
                    animation: Looks.transition.opacity.createObject(this)
                }
            }
        }

        // ホバー
        Rectangle {
            visible: mouse.containsMouse
            x: mouse.hoverIndex * root.cellSize + 1
            y: 1
            width: root.cellSize - 2
            height: root.cellSize - 2
            radius: height / 2
            color: ColorUtils.transparentize(Looks.colors.fg, 0.88)
        }

        // アクティブ(尾を引いて動く)
        Rectangle {
            property real idx1: root.activeIndex
            property real idx2: root.activeIndex
            Behavior on idx1 {
                NumberAnimation { duration: 90; easing.type: Easing.OutCubic }
            }
            Behavior on idx2 {
                NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
            }

            x: Math.min(idx1, idx2) * root.cellSize + 1
            y: 1
            width: Math.abs(idx1 - idx2) * root.cellSize + root.cellSize - 2
            height: root.cellSize - 2
            radius: height / 2
            color: Looks.colors.accent
        }

        // 中身(アイコン / 数字 / 点)
        Repeater {
            model: root.shownCount
            delegate: Item {
                id: cell
                required property int index
                readonly property int wsId: root.group * root.shownCount + index + 1
                readonly property var win: root.mainWindowFor(wsId)
                readonly property bool active: wsId === root.activeWorkspace

                x: index * root.cellSize
                width: root.cellSize
                height: root.cellSize

                // 点(普通のときの空のワークスペース)
                Rectangle {
                    anchors.centerIn: parent
                    opacity: (!cell.win && !root.showNumbers && !root.superHeld) ? 1 : 0
                    visible: opacity > 0
                    implicitWidth: cell.active ? 6 : 4
                    implicitHeight: implicitWidth
                    radius: width / 2
                    color: cell.active ? Looks.colors.accentFg : Looks.colors.subfg

                    Behavior on implicitWidth {
                        animation: Looks.transition.enter.createObject(this)
                    }
                    Behavior on opacity {
                        animation: Looks.transition.opacity.createObject(this)
                    }
                }

                // 数字(長押し中は全部、showNumbers のときは空のワークスペース)
                WText {
                    anchors.centerIn: parent
                    opacity: (root.superHeld || (!cell.win && root.showNumbers)) ? 1 : 0
                    visible: opacity > 0
                    text: String(cell.wsId)
                    font.pixelSize: 12
                    color: cell.active ? Looks.colors.accentFg : (cell.win ? Looks.colors.fg : Looks.colors.subfg)

                    Behavior on opacity {
                        animation: Looks.transition.opacity.createObject(this)
                    }
                }

                // アプリのアイコン(長押し中は縮んで右下へ)
                WAppIcon {
                    id: appIcon
                    opacity: cell.win ? 1 : 0
                    visible: opacity > 0
                    iconName: AppSearch.guessIcon(cell.win?.class)
                    tryCustomIcon: false
                    implicitSize: root.iconSize

                    scale: root.superHeld ? root.shrunkIconSize / root.iconSize : 1
                    x: (root.superHeld ? cell.width - root.shrunkIconSize / 2 + 1 : cell.width / 2) - width / 2
                    y: (root.superHeld ? cell.height - root.shrunkIconSize / 2 + 1 : cell.height / 2) - height / 2

                    Behavior on scale {
                        animation: Looks.transition.move.createObject(this)
                    }
                    Behavior on x {
                        animation: Looks.transition.move.createObject(this)
                    }
                    Behavior on y {
                        animation: Looks.transition.move.createObject(this)
                    }
                    Behavior on opacity {
                        animation: Looks.transition.opacity.createObject(this)
                    }
                }
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            readonly property int hoverIndex: Math.max(0, Math.min(root.shownCount - 1, Math.floor(mouseX / root.cellSize)))

            onClicked: {
                Hyprland.dispatch(`hl.dsp.focus({workspace = ${root.group * root.shownCount + hoverIndex + 1}})`);
            }
            onWheel: event => {
                if (event.angleDelta.y < 0)
                    Hyprland.dispatch(`hl.dsp.focus({workspace = "r+1"})`);
                else if (event.angleDelta.y > 0)
                    Hyprland.dispatch(`hl.dsp.focus({workspace = "r-1"})`);
            }
        }
    }
}