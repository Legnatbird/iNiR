pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

Item {
    id: root
    Layout.fillWidth: true
    implicitHeight: content.implicitHeight
    
    readonly property bool inirEverywhere: Appearance.inirEverywhere
    readonly property bool auroraEverywhere: Appearance.auroraEverywhere

    Rectangle {
        id: content
        anchors.fill: parent
        implicitHeight: systemLayout.implicitHeight + 24
        radius: root.inirEverywhere ? Appearance.inir.roundingNormal : Appearance.rounding.normal
        color: root.inirEverywhere ? Appearance.inir.colLayer1
             : root.auroraEverywhere ? Appearance.aurora.colSubSurface
             : Appearance.colors.colLayer1
        border.width: root.inirEverywhere ? 1 : 0
        border.color: Appearance.inir.colBorder

        ColumnLayout {
            id: systemLayout
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                MaterialSymbol {
                    text: "memory"
                    iconSize: 18
                    color: root.inirEverywhere ? Appearance.inir.colPrimary : Appearance.colors.colPrimary
                }

                StyledText {
                    text: Translation.tr("System")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Medium
                    color: root.inirEverywhere ? Appearance.inir.colText : Appearance.colors.colOnLayer1
                }

                Item { Layout.fillWidth: true }

                StyledText {
                    text: SystemInfo.hostname
                    font.pixelSize: Appearance.font.pixelSize.smallest
                    color: root.inirEverywhere ? Appearance.inir.colTextSecondary : Appearance.colors.colSubtext
                }
            }

            // Stats grid
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 8
                columnSpacing: 8

                // CPU
                SystemStatCard {
                    icon: "developer_board"
                    label: "CPU"
                    value: ResourceUsage.cpuPercent.toFixed(0) + "%"
                    progress: ResourceUsage.cpuPercent / 100
                    progressColor: ResourceUsage.cpuPercent > 80 
                        ? Appearance.colors.colError 
                        : (root.inirEverywhere ? Appearance.inir.colPrimary : Appearance.colors.colPrimary)
                }

                // Memory
                SystemStatCard {
                    icon: "memory"
                    label: Translation.tr("Memory")
                    value: ResourceUsage.memPercent.toFixed(0) + "%"
                    subValue: `${(ResourceUsage.memUsed / 1024 / 1024 / 1024).toFixed(1)} / ${(ResourceUsage.memTotal / 1024 / 1024 / 1024).toFixed(1)} GB`
                    progress: ResourceUsage.memPercent / 100
                    progressColor: ResourceUsage.memPercent > 85 
                        ? Appearance.colors.colError 
                        : (root.inirEverywhere ? Appearance.inir.colPrimary : Appearance.colors.colPrimary)
                }

                // Battery (if available)
                Loader {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    active: Battery.available
                    sourceComponent: SystemStatCard {
                        icon: Battery.charging ? "battery_charging_full" 
                            : Battery.percentage > 80 ? "battery_full"
                            : Battery.percentage > 50 ? "battery_5_bar"
                            : Battery.percentage > 20 ? "battery_3_bar"
                            : "battery_1_bar"
                        label: Translation.tr("Battery")
                        value: Battery.percentage.toFixed(0) + "%"
                        subValue: Battery.charging ? Translation.tr("Charging") : Translation.tr("Discharging")
                        progress: Battery.percentage / 100
                        progressColor: Battery.percentage < 20 
                            ? Appearance.colors.colError 
                            : Battery.charging 
                                ? Appearance.colors.colSuccess 
                                : (root.inirEverywhere ? Appearance.inir.colPrimary : Appearance.colors.colPrimary)
                    }
                }

                // Network
                SystemStatCard {
                    icon: Network.materialSymbol
                    label: Translation.tr("Network")
                    value: Network.ssid || Network.type || Translation.tr("Disconnected")
                    subValue: Network.ip || ""
                }

                // Bluetooth
                SystemStatCard {
                    visible: BluetoothStatus.available
                    icon: BluetoothStatus.connected ? "bluetooth_connected" 
                        : BluetoothStatus.enabled ? "bluetooth" 
                        : "bluetooth_disabled"
                    label: "Bluetooth"
                    value: BluetoothStatus.connected ? Translation.tr("Connected")
                        : BluetoothStatus.enabled ? Translation.tr("Enabled")
                        : Translation.tr("Disabled")
                }
            }
        }
    }

    component SystemStatCard: Rectangle {
        property string icon
        property string label
        property string value
        property string subValue: ""
        property real progress: -1
        property color progressColor: root.inirEverywhere ? Appearance.inir.colPrimary : Appearance.colors.colPrimary

        Layout.fillWidth: true
        implicitHeight: statCardLayout.implicitHeight + 16
        radius: root.inirEverywhere ? Appearance.inir.roundingSmall : Appearance.rounding.small
        color: root.inirEverywhere ? Appearance.inir.colLayer2
             : root.auroraEverywhere ? ColorUtils.transparentize(Appearance.aurora.colSubSurface, 0.5)
             : Appearance.colors.colLayer2
        border.width: root.inirEverywhere ? 1 : 0
        border.color: Appearance.inir.colBorderSubtle

        ColumnLayout {
            id: statCardLayout
            anchors.fill: parent
            anchors.margins: 8
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                MaterialSymbol {
                    text: icon
                    iconSize: 16
                    color: root.inirEverywhere ? Appearance.inir.colTextSecondary : Appearance.colors.colSubtext
                }

                StyledText {
                    text: label
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: root.inirEverywhere ? Appearance.inir.colTextSecondary : Appearance.colors.colSubtext
                }

                Item { Layout.fillWidth: true }

                StyledText {
                    text: value
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Medium
                    font.family: Appearance.font.family.numbers
                    color: root.inirEverywhere ? Appearance.inir.colText : Appearance.colors.colOnLayer1
                }
            }

            StyledText {
                visible: subValue !== ""
                text: subValue
                font.pixelSize: Appearance.font.pixelSize.smallest
                color: root.inirEverywhere ? Appearance.inir.colTextSecondary : Appearance.colors.colSubtext
            }

            // Progress bar
            Rectangle {
                visible: progress >= 0
                Layout.fillWidth: true
                height: 4
                radius: 2
                color: root.inirEverywhere ? Appearance.inir.colLayer1 
                    : root.auroraEverywhere ? Appearance.aurora.colSubSurface
                    : Appearance.colors.colLayer1

                Rectangle {
                    width: parent.width * Math.max(0, Math.min(1, progress))
                    height: parent.height
                    radius: 2
                    color: progressColor

                    Behavior on width {
                        enabled: Appearance.animationsEnabled
                        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                    }
                }
            }
        }
    }
}
