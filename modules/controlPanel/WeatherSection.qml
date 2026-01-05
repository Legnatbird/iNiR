pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

Item {
    id: root
    Layout.fillWidth: true
    implicitHeight: visible ? content.implicitHeight + 16 : 0
    visible: Weather.enabled && Weather.data.temp && !Weather.data.temp.startsWith("--")
    
    readonly property bool inirEverywhere: Appearance.inirEverywhere
    readonly property bool auroraEverywhere: Appearance.auroraEverywhere

    Rectangle {
        id: content
        anchors.fill: parent
        radius: root.inirEverywhere ? Appearance.inir.roundingNormal : Appearance.rounding.normal
        color: root.inirEverywhere ? Appearance.inir.colLayer1
             : root.auroraEverywhere ? Appearance.aurora.colSubSurface
             : Appearance.colors.colLayer1
        border.width: root.inirEverywhere ? 1 : 0
        border.color: Appearance.inir.colBorder

        implicitHeight: weatherLayout.implicitHeight + 24

        ColumnLayout {
            id: weatherLayout
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            // Header row
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                MaterialSymbol {
                    text: Icons.getWeatherIcon(Weather.data.wCode, Weather.isNightNow()) ?? "cloud"
                    iconSize: 48
                    color: root.inirEverywhere ? Appearance.inir.colPrimary : Appearance.colors.colPrimary
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    StyledText {
                        text: Weather.data.temp
                        font.pixelSize: Appearance.font.pixelSize.huge * 1.8
                        font.weight: Font.Medium
                        font.family: Appearance.font.family.numbers
                        color: root.inirEverywhere ? Appearance.inir.colText : Appearance.colors.colOnLayer1
                    }

                    StyledText {
                        text: Weather.data.description || Translation.tr("Weather")
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: root.inirEverywhere ? Appearance.inir.colTextSecondary : Appearance.colors.colSubtext
                    }
                }

                Item { Layout.fillWidth: true }

                ColumnLayout {
                    spacing: 2
                    Layout.alignment: Qt.AlignRight

                    StyledText {
                        Layout.alignment: Qt.AlignRight
                        text: Weather.data.city
                        font.pixelSize: Appearance.font.pixelSize.small
                        font.weight: Font.Medium
                        color: root.inirEverywhere ? Appearance.inir.colText : Appearance.colors.colOnLayer1
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignRight
                        text: Translation.tr("Feels like") + " " + Weather.data.tempFeelsLike
                        font.pixelSize: Appearance.font.pixelSize.smallest
                        color: root.inirEverywhere ? Appearance.inir.colTextSecondary : Appearance.colors.colSubtext
                        visible: Weather.data.tempFeelsLike && !Weather.data.tempFeelsLike.startsWith("--")
                    }
                }

                RippleButton {
                    implicitWidth: 32
                    implicitHeight: 32
                    buttonRadius: root.inirEverywhere ? Appearance.inir.roundingSmall : Appearance.rounding.full
                    colBackground: "transparent"
                    colBackgroundHover: root.inirEverywhere ? Appearance.inir.colLayer2Hover 
                        : root.auroraEverywhere ? Appearance.aurora.colSubSurface 
                        : Appearance.colors.colLayer2Hover
                    colRipple: root.inirEverywhere ? Appearance.inir.colLayer2Active 
                        : root.auroraEverywhere ? Appearance.aurora.colSubSurfaceActive 
                        : Appearance.colors.colLayer2Active
                    onClicked: Weather.fetchWeather()

                    contentItem: Item {
                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "refresh"
                            iconSize: 18
                            color: root.inirEverywhere ? Appearance.inir.colTextSecondary : Appearance.colors.colSubtext
                        }
                    }

                    StyledToolTip { text: Translation.tr("Refresh") }
                }
            }

            // Stats grid
            GridLayout {
                Layout.fillWidth: true
                columns: 4
                rowSpacing: 8
                columnSpacing: 8

                WeatherStatCard { icon: "humidity_percentage"; label: Translation.tr("Humidity"); value: Weather.data.humidity }
                WeatherStatCard { icon: "air"; label: Translation.tr("Wind"); value: Weather.data.wind + " " + Weather.data.windDir }
                WeatherStatCard { icon: "sunny"; label: Translation.tr("UV Index"); value: Weather.data.uv }
                WeatherStatCard { icon: "water_drop"; label: Translation.tr("Precipitation"); value: Weather.data.precip }
                WeatherStatCard { icon: "visibility"; label: Translation.tr("Visibility"); value: Weather.data.visib }
                WeatherStatCard { icon: "speed"; label: Translation.tr("Pressure"); value: Weather.data.press }
                WeatherStatCard { icon: "wb_twilight"; label: Translation.tr("Sunrise"); value: Weather.data.sunrise }
                WeatherStatCard { icon: "nights_stay"; label: Translation.tr("Sunset"); value: Weather.data.sunset }
            }
        }
    }

    component WeatherStatCard: Rectangle {
        property string icon
        property string label
        property string value

        Layout.fillWidth: true
        implicitHeight: statLayout.implicitHeight + 12
        radius: root.inirEverywhere ? Appearance.inir.roundingSmall : Appearance.rounding.small
        color: root.inirEverywhere ? Appearance.inir.colLayer2
             : root.auroraEverywhere ? ColorUtils.transparentize(Appearance.aurora.colSubSurface, 0.5)
             : Appearance.colors.colLayer2
        border.width: root.inirEverywhere ? 1 : 0
        border.color: Appearance.inir.colBorderSubtle

        ColumnLayout {
            id: statLayout
            anchors.fill: parent
            anchors.margins: 6
            spacing: 2

            RowLayout {
                spacing: 4
                MaterialSymbol {
                    text: icon
                    iconSize: 12
                    color: root.inirEverywhere ? Appearance.inir.colTextSecondary : Appearance.colors.colSubtext
                }
                StyledText {
                    text: label
                    font.pixelSize: Appearance.font.pixelSize.smallest
                    color: root.inirEverywhere ? Appearance.inir.colTextSecondary : Appearance.colors.colSubtext
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }

            StyledText {
                text: value || "--"
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.Medium
                font.family: Appearance.font.family.numbers
                color: root.inirEverywhere ? Appearance.inir.colText : Appearance.colors.colOnLayer1
            }
        }
    }
}
