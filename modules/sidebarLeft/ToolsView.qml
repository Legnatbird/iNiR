pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import "root:"

Item {
    id: root

    // Local state for niri toggles (not exposed via IPC)
    property bool _debugTint: false
    property bool _showDamage: false
    property bool _opaqueRegions: false

    Flickable {
        id: flickable
        anchors.fill: parent
        anchors.margins: 8
        contentHeight: mainColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: mainColumn
            width: flickable.width
            spacing: 16

            // === Quick Toggles ===
            CollapsibleSection {
                title: Translation.tr("Quick Toggles")
                icon: "toggle_on"
                expanded: true
                enableSettingsSearch: false

                ConfigSwitch {
                    buttonIcon: "dark_mode"
                    text: Translation.tr("Dark mode")
                    checked: Appearance.m3colors?.darkmode ?? false
                    onCheckedChanged: {
                        const current = Config.options?.appearance?.customTheme?.darkmode ?? true
                        if (checked !== current) Config.setNestedValue("appearance.customTheme.darkmode", checked)
                    }
                }
                ConfigSwitch {
                    buttonIcon: "nightlight"
                    text: Translation.tr("Night light")
                    checked: Hyprsunset.active ?? false
                    onCheckedChanged: if (checked !== Hyprsunset.active) Hyprsunset.toggle()
                }
                ConfigSwitch {
                    buttonIcon: "coffee"
                    text: Translation.tr("Idle inhibitor")
                    checked: Idle.inhibit ?? false
                    onCheckedChanged: if (checked !== Idle.inhibit) Idle.toggleInhibit()
                }
                ConfigSwitch {
                    buttonIcon: "do_not_disturb_on"
                    text: Translation.tr("Do not disturb")
                    checked: Notifications.silent ?? false
                    onCheckedChanged: if (checked !== Notifications.silent) Notifications.toggleSilent()
                }
                ConfigSwitch {
                    buttonIcon: "sports_esports"
                    text: Translation.tr("Game mode")
                    checked: GameMode.active
                    onCheckedChanged: if (checked !== GameMode.active) GameMode.toggle()
                }
            }

            // === Capture ===
            CollapsibleSection {
                title: Translation.tr("Capture")
                icon: "screenshot"
                expanded: true
                enableSettingsSearch: false

                ActionButton {
                    btnIcon: "screenshot"
                    label: Translation.tr("Screenshot")
                    onClicked: Quickshell.execDetached(["niri", "msg", "action", "screenshot"])
                }
                ActionButton {
                    btnIcon: "screenshot_region"
                    label: Translation.tr("Region screenshot")
                    onClicked: Quickshell.execDetached(["/usr/bin/qs", "-c", "ii", "ipc", "call", "region", "screenshot"])
                }
                ActionButton {
                    btnIcon: "videocam"
                    label: Translation.tr("Screen record")
                    onClicked: Quickshell.execDetached(["/usr/bin/qs", "-c", "ii", "ipc", "call", "region", "record"])
                }
                ActionButton {
                    btnIcon: "text_fields"
                    label: Translation.tr("OCR (text recognition)")
                    onClicked: Quickshell.execDetached(["/usr/bin/qs", "-c", "ii", "ipc", "call", "region", "ocr"])
                }
                ActionButton {
                    btnIcon: "colorize"
                    label: Translation.tr("Color picker")
                    onClicked: Quickshell.execDetached(["niri", "msg", "action", "pick-color"])
                }
            }

            // === Clipboard ===
            CollapsibleSection {
                title: Translation.tr("Clipboard")
                icon: "content_paste"
                expanded: false
                enableSettingsSearch: false

                ActionButton {
                    btnIcon: "assignment"
                    label: Translation.tr("Open clipboard")
                    onClicked: GlobalStates.clipboardOpen = true
                }
                ActionButton {
                    btnIcon: "delete_sweep"
                    label: Translation.tr("Clear clipboard history")
                    onClicked: Cliphist.wipe()
                }
            }

            // === Quick Launch ===
            CollapsibleSection {
                title: Translation.tr("Quick Launch")
                icon: "rocket_launch"
                expanded: false
                enableSettingsSearch: false

                ActionButton {
                    btnIcon: "terminal"
                    label: Translation.tr("Terminal")
                    onClicked: Quickshell.execDetached([Config.options?.apps?.terminal ?? "/usr/bin/foot"])
                }
                ActionButton {
                    btnIcon: "folder"
                    label: Translation.tr("File manager")
                    onClicked: Quickshell.execDetached(["/usr/bin/nautilus"])
                }
                ActionButton {
                    btnIcon: "settings"
                    label: Translation.tr("Settings")
                    onClicked: Quickshell.execDetached(["/usr/bin/qs", "-c", "ii", "ipc", "call", "settings", "open"])
                }
                ActionButton {
                    btnIcon: "tune"
                    label: Translation.tr("Volume mixer")
                    onClicked: Quickshell.execDetached([Config.options?.apps?.volumeMixer ?? "/usr/bin/pavucontrol"])
                }
            }

            // === Niri Debug ===
            CollapsibleSection {
                title: Translation.tr("Niri Debug")
                icon: "bug_report"
                expanded: false
                enableSettingsSearch: false

                ConfigSwitch {
                    buttonIcon: "palette"
                    text: Translation.tr("Debug tint")
                    checked: root._debugTint
                    onCheckedChanged: {
                        if (root._debugTint !== checked) {
                            root._debugTint = checked
                            Quickshell.execDetached(["niri", "msg", "action", "toggle-debug-tint"])
                        }
                    }
                }
                ConfigSwitch {
                    buttonIcon: "broken_image"
                    text: Translation.tr("Show damage")
                    checked: root._showDamage
                    onCheckedChanged: {
                        if (root._showDamage !== checked) {
                            root._showDamage = checked
                            Quickshell.execDetached(["niri", "msg", "action", "debug-toggle-damage"])
                        }
                    }
                }
                ConfigSwitch {
                    buttonIcon: "select_all"
                    text: Translation.tr("Opaque regions")
                    checked: root._opaqueRegions
                    onCheckedChanged: {
                        if (root._opaqueRegions !== checked) {
                            root._opaqueRegions = checked
                            Quickshell.execDetached(["niri", "msg", "action", "debug-toggle-opaque-regions"])
                        }
                    }
                }
                ActionButton {
                    btnIcon: "refresh"
                    label: Translation.tr("Reload Niri config")
                    onClicked: Quickshell.execDetached(["niri", "msg", "action", "load-config-file"])
                }
            }

            // === Shell ===
            CollapsibleSection {
                title: Translation.tr("Shell")
                icon: "deployed_code"
                expanded: false
                enableSettingsSearch: false

                ActionButton {
                    btnIcon: "restart_alt"
                    label: Translation.tr("Restart shell")
                    onClicked: Quickshell.execDetached(["/usr/bin/fish", "-c", "qs kill -c ii; qs -c ii -d"])
                }
                ActionButton {
                    btnIcon: "lock"
                    label: Translation.tr("Lock screen")
                    onClicked: Session.lock()
                }
                ActionButton {
                    btnIcon: "logout"
                    label: Translation.tr("Session menu")
                    onClicked: GlobalStates.sessionOpen = true
                }
            }

            Item { Layout.preferredHeight: 8 }
        }
    }

    // === Action Button Component ===
    component ActionButton: RippleButton {
        property string btnIcon: ""
        property string label: ""

        Layout.fillWidth: true
        implicitHeight: 40
        buttonRadius: Appearance.inirEverywhere ? Appearance.inir.roundingSmall : Appearance.rounding.verysmall

        colBackground: "transparent"
        colBackgroundHover: Appearance.inirEverywhere ? Appearance.inir.colLayer1Hover
                         : Appearance.auroraEverywhere ? Appearance.aurora.colSubSurface
                         : Appearance.colors.colLayer1Hover

        contentItem: RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 10

            MaterialSymbol {
                text: btnIcon
                iconSize: Appearance.font.pixelSize.normal
                color: Appearance.inirEverywhere ? Appearance.inir.colText : Appearance.colors.colOnLayer1
            }
            StyledText {
                text: label
                Layout.fillWidth: true
                color: Appearance.inirEverywhere ? Appearance.inir.colText : Appearance.colors.colOnLayer1
            }
            MaterialSymbol {
                text: "chevron_right"
                iconSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colSubtext
            }
        }
    }
}
