import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.waffle.looks
import qs.modules.waffle.bar.tasks
import qs.modules.waffle.bar.tray
import Quickshell

Rectangle {
    id: root

    readonly property string alignment: Config.options.waffles.bar.alignment

    color: Looks.colors.bg0
    implicitHeight: 48

    function setAlignment(value) {
        Config.options.waffles.bar.alignment = value;
    }
    function alignLabel(value, label) {
        return (root.alignment === value ? "✓  " : "     ") + label;
    }

    // 何もない場所の右クリックでメニューを出す(一番下の層に置く)
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: (event) => {
            menuAnchor.x = event.x;
            barMenu.active = true;
        }
    }
    Item {
        id: menuAnchor
        y: 0
        width: 1
        height: root.height
    }
    BarMenu {
        id: barMenu
        anchorItem: menuAnchor
        model: [
            {
                text: Translation.tr("Task Manager"),
                action: () => {
                    Quickshell.execDetached(["bash", "-c", Config.options.apps.taskManager]);
                }
            },
            {
                text: Translation.tr("Taskbar settings"),
                action: () => {
                    Quickshell.execDetached(["env", "SETTINGS_PAGE=WaffleConfig", "qs", "-p", Quickshell.shellPath("settings.qml")]);
                }
            }
        ]
    }

    Rectangle {
        id: border
        anchors {
            left: parent.left
            right: parent.right
            top: Config.options.waffles.bar.bottom ? parent.top : undefined
            bottom: Config.options.waffles.bar.bottom ? undefined : parent.bottom
        }
        color: Looks.colors.bg0Border
        implicitHeight: 1
    }

    BarGroupRow {
        id: appsRow
        anchors.left: undefined
        anchors.horizontalCenter: parent.horizontalCenter

        states: [
            State {
                name: "left"
                when: root.alignment === "left"
                AnchorChanges {
                    target: appsRow
                    anchors.left: parent.left
                    anchors.horizontalCenter: undefined
                }
            },
            State {
                name: "right"
                when: root.alignment === "right"
                AnchorChanges {
                    target: appsRow
                    anchors.right: systemRow.left
                    anchors.horizontalCenter: undefined
                }
            }
        ]

        transitions: Transition {
            animations: Looks.transition.anchor.createObject(this)
        }

        StartButton {}
        SearchButton {}
        TaskViewButton {}
        Tasks {}
    }

    BarGroupRow {
        id: systemRow
        anchors.right: parent.right
        WorkspacesButton {}
        Tray {}
        UpdatesButton {}
        SystemButton {}
        TimeButton {}
    }

    component BarGroupRow: RowLayout {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        spacing: 0
    }
}