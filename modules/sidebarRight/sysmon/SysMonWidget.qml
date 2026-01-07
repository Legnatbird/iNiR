import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.services
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    property int margin: 10

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.margin
        spacing: 12

        // Header
        RowLayout {
            Layout.fillWidth: true
            StyledText {
                Layout.fillWidth: true
                text: Translation.tr("System Monitor")
                font.pixelSize: Appearance.inirEverywhere ? Appearance.font.pixelSize.normal : Appearance.font.pixelSize.larger
                color: Appearance.inirEverywhere ? Appearance.inir.colText 
                     : Appearance.colors.colOnLayer1
            }
        }

        // Scrollable content
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Appearance.inirEverywhere ? Appearance.inir.roundingNormal : Appearance.rounding.normal
            color: Appearance.inirEverywhere ? Appearance.inir.colLayer0
                : Appearance.auroraEverywhere ? Appearance.aurora.colSubSurface
                : Appearance.colors.colLayer0
            border.width: Appearance.inirEverywhere ? 1 : (Appearance.auroraEverywhere ? 0 : 1)
            border.color: Appearance.inirEverywhere ? Appearance.inir.colBorder : Appearance.colors.colLayer0Border
            clip: true

            Flickable {
                anchors.fill: parent
                // Add padding at the bottom to avoid cutting off last item
                contentHeight: statsColumn.implicitHeight + 40 
                clip: true
                ScrollBar.vertical: ScrollBar { 
                    policy: ScrollBar.AsNeeded 
                    width: 4
                    active: parent.moving || parent.flicking
                }
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: statsColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 10
                    spacing: 15

                    // CPU Section
                    SysGraphItem {
                        title: "CPU"
                        valueText: Math.round(ResourceUsage.cpuUsage * 100) + "%"
                        maxText: ResourceUsage.maxAvailableCpuString
                        graphValues: ResourceUsage.cpuUsageHistory
                        graphColor: Appearance.colors.colPrimary
                    }

                    // RAM Section
                    SysGraphItem {
                        title: "RAM"
                        valueText: Math.round(ResourceUsage.memoryUsedPercentage * 100) + "%"
                        maxText: ResourceUsage.maxAvailableMemoryString
                        subText: (ResourceUsage.memoryUsed / (1024*1024)).toFixed(1) + " GB used"
                        graphValues: ResourceUsage.memoryUsageHistory
                        graphColor: Appearance.colors.colSecondary
                    }
                }
            }
        }
    }

    component SysGraphItem: ColumnLayout {
        required property string title
        required property string valueText
        property string subText: ""
        property string maxText: ""
        required property list<real> graphValues
        property color graphColor: Appearance.colors.colPrimary
        
        Layout.fillWidth: true
        spacing: 5

        RowLayout {
            Layout.fillWidth: true
            StyledText {
                text: title
                font.bold: true
                color: Appearance.inirEverywhere ? Appearance.inir.colText
                     : Appearance.colors.colOnLayer0
            }
            Item { Layout.fillWidth: true }
            StyledText {
                text: valueText
                font.bold: true
                color: graphColor
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            
            // Background grid/lines could be added here
            
            Graph {
                anchors.fill: parent
                
                property real maxValue: {
                    let max = 0
                    for(let i=0; i<graphValues.length; i++) {
                        if(graphValues[i] > max) max = graphValues[i]
                    }
                    return max > 1 ? max : 1
                }

                values: {
                    let res = []
                    for(let i=0; i<graphValues.length; i++) {
                        res.push(graphValues[i] / maxValue)
                    }
                    return res
                }
                
                color: graphColor
                fillOpacity: 0.2
                alignment: Graph.Alignment.Right
            }
            
            // Border
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.width: 0
                border.color: "transparent"
                radius: 4
            }
        }
        
        RowLayout {
            visible: subText !== "" || maxText !== ""
            Layout.fillWidth: true
            StyledText {
                visible: subText !== ""
                text: subText
                font.pixelSize: Appearance.font.pixelSize.smallest
                color: Appearance.colors.colSubtext
            }
            Item { Layout.fillWidth: true }
             StyledText {
                visible: maxText !== ""
                text: Translation.tr("Max: %1").arg(maxText)
                font.pixelSize: Appearance.font.pixelSize.smallest
                color: Appearance.colors.colSubtext
            }
        }
    }
}
