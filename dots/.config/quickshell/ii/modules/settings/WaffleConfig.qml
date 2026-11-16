import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    forceWidth: true

        ContentSection {
        icon: "bottom_app_bar"
        title: Translation.tr("Taskbar")

        ContentSubsection {
            title: Translation.tr("Icon alignment")

            ConfigSelectionArray {
                currentValue: Config.options.waffles.bar.alignment
                onSelected: newValue => {
                    Config.options.waffles.bar.alignment = newValue;
                }
                options: [
                    {
                        displayName: Translation.tr("Left"),
                        icon: "align_horizontal_left",
                        value: "left"
                    },
                    {
                        displayName: Translation.tr("Center"),
                        icon: "align_horizontal_center",
                        value: "center"
                    },
                    {
                        displayName: Translation.tr("Right"),
                        icon: "align_horizontal_right",
                        value: "right"
                    }
                ]
            }
        }
    }

    ContentSection {
        icon: "grid_view"
        title: Translation.tr("Taskbar workspaces")

        ConfigSwitch {
            buttonIcon: "visibility"
            text: Translation.tr("Show workspaces")
            checked: Config.options.waffles.bar.workspaces.show
            onCheckedChanged: {
                Config.options.waffles.bar.workspaces.show = checked;
            }
        }
        ConfigSwitch {
            buttonIcon: "counter_1"
            text: Translation.tr("Show numbers on empty workspaces")
            checked: Config.options.waffles.bar.workspaces.showNumbers
            onCheckedChanged: {
                Config.options.waffles.bar.workspaces.showNumbers = checked;
            }
        }
        ConfigSpinBox {
            icon: "format_list_numbered"
            text: Translation.tr("Workspaces shown")
            value: Config.options.waffles.bar.workspaces.shownCount
            from: 1
            to: 10
            stepSize: 1
            onValueChanged: {
                Config.options.waffles.bar.workspaces.shownCount = value;
            }
        }
        ConfigSpinBox {
            icon: "width"
            text: Translation.tr("Cell size")
            value: Config.options.waffles.bar.workspaces.cellSize
            from: 16
            to: 40
            stepSize: 1
            onValueChanged: {
                Config.options.waffles.bar.workspaces.cellSize = value;
            }
        }
        ConfigSpinBox {
            icon: "image"
            text: Translation.tr("Icon size")
            value: Config.options.waffles.bar.workspaces.iconSize
            from: 10
            to: 32
            stepSize: 1
            onValueChanged: {
                Config.options.waffles.bar.workspaces.iconSize = value;
            }
        }
        ConfigSpinBox {
            icon: "space_bar"
            text: Translation.tr("Padding")
            value: Config.options.waffles.bar.workspaces.padding
            from: 0
            to: 8
            stepSize: 1
            onValueChanged: {
                Config.options.waffles.bar.workspaces.padding = value;
            }
        }
    }
}