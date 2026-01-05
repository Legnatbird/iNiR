import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root
    Layout.fillWidth: true
    implicitHeight: dateTimeRow.implicitHeight + 16
    
    readonly property bool inirEverywhere: Appearance.inirEverywhere
    readonly property bool auroraEverywhere: Appearance.auroraEverywhere

    Rectangle {
        anchors.fill: parent
        radius: root.inirEverywhere ? Appearance.inir.roundingNormal : Appearance.rounding.normal
        color: root.inirEverywhere ? Appearance.inir.colLayer1
             : root.auroraEverywhere ? Appearance.aurora.colSubSurface
             : Appearance.colors.colLayer1
        border.width: root.inirEverywhere ? 1 : 0
        border.color: Appearance.inir.colBorder

        RowLayout {
            id: dateTimeRow
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                StyledText {
                    text: Qt.formatDateTime(new Date(), "dddd")
                    font.pixelSize: Appearance.font.pixelSize.small
                    font.weight: Font.Medium
                    color: root.inirEverywhere ? Appearance.inir.colPrimary : Appearance.colors.colPrimary
                }

                StyledText {
                    text: Qt.formatDateTime(new Date(), "MMMM d, yyyy")
                    font.pixelSize: Appearance.font.pixelSize.larger
                    font.weight: Font.Medium
                    color: root.inirEverywhere ? Appearance.inir.colText : Appearance.colors.colOnLayer1
                }

                StyledText {
                    text: Translation.tr("Uptime") + ": " + DateTime.uptime
                    font.pixelSize: Appearance.font.pixelSize.smallest
                    color: root.inirEverywhere ? Appearance.inir.colTextSecondary : Appearance.colors.colSubtext
                }
            }

            StyledText {
                text: DateTime.time
                font.pixelSize: Appearance.font.pixelSize.huge * 1.5
                font.weight: Font.Light
                font.family: Appearance.font.family.numbers
                color: root.inirEverywhere ? Appearance.inir.colText : Appearance.colors.colOnLayer1
            }
        }
    }

    Timer {
        interval: 1000
        running: GlobalStates.controlPanelOpen
        repeat: true
        onTriggered: root.update()
    }

    function update() {
        // Force re-evaluation of date bindings
    }
}
