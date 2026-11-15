import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.modules.common
import qs.modules.waffle.looks

BarButton {
    id: root

    topInset: 8       // 高さ 48 - 16 = 32px
    bottomInset: 8
    leftInset: 6
    rightInset: 6
    implicitWidth: 200
    horizontalPadding: 12

    checked: GlobalStates.searchOpen && LauncherSearch.query !== ""
    onClicked: {
        GlobalStates.searchOpen = !GlobalStates.searchOpen; // For now...
    }

    background: AcrylicRectangle {
        shiny: root.hovered || root.checked
        radius: height / 2
        color: (root.hovered || root.checked) ? Looks.colors.bg2Hover : Looks.colors.bg1
        border.width: 1
        border.color: Looks.colors.bg0Border
    }

    contentItem: RowLayout {
        spacing: 10
        WAppIcon {
            iconName: "system-search"
            separateLightDark: true
            implicitSize: 16
        }
        WText {
            Layout.fillWidth: true
            text: Translation.tr("Search")
            color: Looks.colors.subfg
        }
    }

    BarToolTip {
        text: Translation.tr("Search")
        extraVisibleCondition: root.shouldShowTooltip
    }
}