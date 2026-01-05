pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root
    Layout.fillWidth: true
    implicitHeight: content.implicitHeight
    
    readonly property bool inirEverywhere: Appearance.inirEverywhere
    readonly property bool auroraEverywhere: Appearance.auroraEverywhere

    Rectangle {
        id: content
        anchors.fill: parent
        implicitHeight: actionsLayout.implicitHeight + 24
        radius: root.inirEverywhere ? Appearance.inir.roundingNormal : Appearance.rounding.normal
        color: root.inirEverywhere ? Appearance.inir.colLayer1
             : root.auroraEverywhere ? Appearance.aurora.colSubSurface
             : Appearance.colors.colLayer1
        border.width: root.inirEverywhere ? 1 : 0
        border.color: Appearance.inir.colBorder

        ColumnLayout {
            id: actionsLayout
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                MaterialSymbol {
                    text: "bolt"
                    iconSize: 18
                    color: root.inirEverywhere ? Appearance.inir.colPrimary : Appearance.colors.colPrimary
                }

                StyledText {
                    text: Translation.tr("Quick Actions")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Medium
                    color: root.inirEverywhere ? Appearance.inir.colText : Appearance.colors.colOnLayer1
                }

                Item { Layout.fillWidth: true }
            }

            // Actions grid - Row 1: Audio & Connectivity
            GridLayout {
                Layout.fillWidth: true
                columns: 4
                rowSpacing: 8
                columnSpacing: 8

                QuickActionButton {
                    icon: Audio.sink?.audio?.muted ? "volume_off" : "volume_up"
                    label: Translation.tr("Sound")
                    active: !(Audio.sink?.audio?.muted ?? false)
                    onClicked: {
                        if (Audio.sink?.audio) {
                            Audio.sink.audio.muted = !Audio.sink.audio.muted
                        }
                    }
                }

                QuickActionButton {
                    icon: Audio.source?.audio?.muted ? "mic_off" : "mic"
                    label: Translation.tr("Mic")
                    active: !(Audio.source?.audio?.muted ?? false)
                    onClicked: {
                        if (Audio.source?.audio) {
                            Audio.source.audio.muted = !Audio.source.audio.muted
                        }
                    }
                }

                QuickActionButton {
                    icon: Network.wifiEnabled ? Network.materialSymbol : "wifi_off"
                    label: "WiFi"
                    active: Network.wifiEnabled
                    onClicked: Network.toggleWifi()
                }

                QuickActionButton {
                    visible: BluetoothStatus.available
                    icon: BluetoothStatus.enabled ? "bluetooth" : "bluetooth_disabled"
                    label: "Bluetooth"
                    active: BluetoothStatus.enabled
                    onClicked: BluetoothStatus.toggle()
                }

                // Row 2: Display & Notifications
                QuickActionButton {
                    icon: Notifications.silent ? "notifications_off" : "notifications"
                    label: Translation.tr("DND")
                    active: Notifications.silent
                    onClicked: Notifications.silent = !Notifications.silent
                }

                QuickActionButton {
                    icon: "dark_mode"
                    label: Translation.tr("Dark")
                    active: Appearance.m3colors.darkmode
                    onClicked: {
                        const newMode = !Appearance.m3colors.darkmode
                        Config.setNestedValue("appearance.darkMode", newMode)
                    }
                }

                QuickActionButton {
                    icon: "nightlight"
                    label: Translation.tr("Night")
                    active: Hyprsunset.active
                    onClicked: Hyprsunset.toggle()
                }

                QuickActionButton {
                    icon: Idle.inhibit ? "coffee" : "coffee"
                    label: Translation.tr("Caffeine")
                    active: Idle.inhibit
                    onClicked: Idle.toggleInhibit()
                }

                // Row 3: Performance & System
                QuickActionButton {
                    icon: "sports_esports"
                    label: Translation.tr("Game")
                    active: GameMode.active
                    onClicked: GameMode.toggle()
                }

                QuickActionButton {
                    icon: "screenshot_monitor"
                    label: Translation.tr("Screenshot")
                    onClicked: {
                        GlobalStates.controlPanelOpen = false
                        GlobalStates.regionSelectorOpen = true
                    }
                }

                QuickActionButton {
                    icon: "settings"
                    label: Translation.tr("Settings")
                    onClicked: {
                        GlobalStates.controlPanelOpen = false
                        Quickshell.exec(["fish", "-c", "qs ipc call -c ii settings openSettingsDialog"])
                    }
                }

                QuickActionButton {
                    icon: "power_settings_new"
                    label: Translation.tr("Session")
                    onClicked: {
                        GlobalStates.controlPanelOpen = false
                        GlobalStates.sessionOpen = true
                    }
                }
            }
        }
    }

    component QuickActionButton: Rectangle {
        id: actionButton
        property string icon
        property string label
        property bool active: false
        signal clicked()

        Layout.fillWidth: true
        implicitHeight: actionLayout.implicitHeight + 16
        radius: root.inirEverywhere ? Appearance.inir.roundingSmall : Appearance.rounding.small
        color: actionMouseArea.containsMouse 
            ? (active 
                ? (root.inirEverywhere ? Appearance.inir.colPrimaryActive : Appearance.colors.colPrimaryActive)
                : (root.inirEverywhere ? Appearance.inir.colLayer2Hover : Appearance.colors.colLayer2Hover))
            : (active 
                ? (root.inirEverywhere ? Appearance.inir.colPrimary : Appearance.colors.colPrimary)
                : (root.inirEverywhere ? Appearance.inir.colLayer2 : Appearance.colors.colLayer2))
        border.width: root.inirEverywhere ? 1 : 0
        border.color: active ? Appearance.inir.colPrimary : Appearance.inir.colBorderSubtle

        Behavior on color {
            enabled: Appearance.animationsEnabled
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }

        ColumnLayout {
            id: actionLayout
            anchors.centerIn: parent
            spacing: 4

            MaterialSymbol {
                Layout.alignment: Qt.AlignHCenter
                text: icon
                iconSize: 20
                fill: active ? 1 : 0
                color: active 
                    ? (root.inirEverywhere ? Appearance.inir.colOnPrimary : Appearance.colors.colOnPrimary)
                    : (root.inirEverywhere ? Appearance.inir.colText : Appearance.colors.colOnLayer1)

                Behavior on color {
                    enabled: Appearance.animationsEnabled
                    animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                }
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: label
                font.pixelSize: Appearance.font.pixelSize.smallest
                color: active 
                    ? (root.inirEverywhere ? Appearance.inir.colOnPrimary : Appearance.colors.colOnPrimary)
                    : (root.inirEverywhere ? Appearance.inir.colTextSecondary : Appearance.colors.colSubtext)
                horizontalAlignment: Text.AlignHCenter

                Behavior on color {
                    enabled: Appearance.animationsEnabled
                    animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                }
            }
        }

        MouseArea {
            id: actionMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: actionButton.clicked()
        }
    }
}
