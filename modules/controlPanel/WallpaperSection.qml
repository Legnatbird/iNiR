pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects as GE
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
        implicitHeight: wallpaperLayout.implicitHeight + 24
        radius: root.inirEverywhere ? Appearance.inir.roundingNormal : Appearance.rounding.normal
        color: root.inirEverywhere ? Appearance.inir.colLayer1
             : root.auroraEverywhere ? Appearance.aurora.colSubSurface
             : Appearance.colors.colLayer1
        border.width: root.inirEverywhere ? 1 : 0
        border.color: Appearance.inir.colBorder

        ColumnLayout {
            id: wallpaperLayout
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                MaterialSymbol {
                    text: "wallpaper"
                    iconSize: 18
                    color: root.inirEverywhere ? Appearance.inir.colPrimary : Appearance.colors.colPrimary
                }

                StyledText {
                    text: Translation.tr("Wallpaper")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Medium
                    color: root.inirEverywhere ? Appearance.inir.colText : Appearance.colors.colOnLayer1
                }

                Item { Layout.fillWidth: true }

                RippleButton {
                    implicitWidth: 28
                    implicitHeight: 28
                    buttonRadius: root.inirEverywhere ? Appearance.inir.roundingSmall : Appearance.rounding.full
                    colBackground: "transparent"
                    colBackgroundHover: root.inirEverywhere ? Appearance.inir.colLayer2Hover 
                        : root.auroraEverywhere ? Appearance.aurora.colSubSurface 
                        : Appearance.colors.colLayer2Hover
                    colRipple: root.inirEverywhere ? Appearance.inir.colLayer2Active 
                        : root.auroraEverywhere ? Appearance.aurora.colSubSurfaceActive 
                        : Appearance.colors.colLayer2Active
                    onClicked: Wallpapers.randomFromCurrentFolder()

                    contentItem: Item {
                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "shuffle"
                            iconSize: 16
                            color: root.inirEverywhere ? Appearance.inir.colTextSecondary : Appearance.colors.colSubtext
                        }
                    }

                    StyledToolTip { text: Translation.tr("Random") }
                }

                RippleButton {
                    implicitWidth: 28
                    implicitHeight: 28
                    buttonRadius: root.inirEverywhere ? Appearance.inir.roundingSmall : Appearance.rounding.full
                    colBackground: "transparent"
                    colBackgroundHover: root.inirEverywhere ? Appearance.inir.colLayer2Hover 
                        : root.auroraEverywhere ? Appearance.aurora.colSubSurface 
                        : Appearance.colors.colLayer2Hover
                    colRipple: root.inirEverywhere ? Appearance.inir.colLayer2Active 
                        : root.auroraEverywhere ? Appearance.aurora.colSubSurfaceActive 
                        : Appearance.colors.colLayer2Active
                    onClicked: GlobalStates.wallpaperSelectorOpen = true

                    contentItem: Item {
                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "folder_open"
                            iconSize: 16
                            color: root.inirEverywhere ? Appearance.inir.colTextSecondary : Appearance.colors.colSubtext
                        }
                    }

                    StyledToolTip { text: Translation.tr("Browse") }
                }
            }

            // Current wallpaper preview
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                radius: root.inirEverywhere ? Appearance.inir.roundingSmall : Appearance.rounding.small
                color: "transparent"
                clip: true

                layer.enabled: true
                layer.effect: GE.OpacityMask {
                    maskSource: Rectangle { 
                        width: parent?.width ?? 100
                        height: 80
                        radius: root.inirEverywhere ? Appearance.inir.roundingSmall : Appearance.rounding.small 
                    }
                }

                Image {
                    anchors.fill: parent
                    source: Wallpapers.effectiveWallpaperUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }

                // Overlay with path
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 24
                    color: ColorUtils.transparentize("black", 0.4)

                    StyledText {
                        anchors.fill: parent
                        anchors.margins: 4
                        text: {
                            const path = Config.options?.background?.wallpaperPath ?? ""
                            if (!path) return ""
                            return path.split("/").pop() || ""
                        }
                        font.pixelSize: Appearance.font.pixelSize.smallest
                        color: "white"
                        elide: Text.ElideMiddle
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            // Quick wallpaper grid
            GridLayout {
                Layout.fillWidth: true
                columns: 5
                rowSpacing: 6
                columnSpacing: 6

                Repeater {
                    model: Math.min(10, Wallpapers.folderModel.count)
                    
                    delegate: Rectangle {
                        id: wallpaperDelegate
                        required property int index
                        required property var modelData
                        
                        readonly property string filePath: Wallpapers.folderModel.get(index, "filePath") ?? ""
                        readonly property string fileName: Wallpapers.folderModel.get(index, "fileName") ?? ""
                        readonly property bool isFolder: Wallpapers.folderModel.get(index, "fileIsDir") ?? false
                        readonly property string thumbnailPath: {
                            if (isFolder || !filePath) return ""
                            const resolvedPath = FileUtils.trimFileProtocol(Qt.resolvedUrl(filePath).toString())
                            const encodedPath = resolvedPath.split("/").map(part => encodeURIComponent(part)).join("/")
                            const md5Hash = Qt.md5("file://" + encodedPath)
                            return `${Directories.genericCache}/thumbnails/normal/${md5Hash}.png`
                        }
                        
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48
                        radius: root.inirEverywhere ? Appearance.inir.roundingSmall : Appearance.rounding.small
                        color: delegateMouseArea.containsMouse 
                            ? (root.inirEverywhere ? Appearance.inir.colLayer2Hover : Appearance.colors.colLayer2Hover)
                            : (root.inirEverywhere ? Appearance.inir.colLayer2 : Appearance.colors.colLayer2)
                        border.width: root.inirEverywhere ? 1 : 0
                        border.color: Appearance.inir.colBorderSubtle
                        clip: true
                        visible: !isFolder

                        Behavior on color {
                            enabled: Appearance.animationsEnabled
                            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                        }

                        layer.enabled: true
                        layer.effect: GE.OpacityMask {
                            maskSource: Rectangle { 
                                width: wallpaperDelegate.width
                                height: 48
                                radius: root.inirEverywhere ? Appearance.inir.roundingSmall : Appearance.rounding.small 
                            }
                        }

                        Image {
                            anchors.fill: parent
                            source: wallpaperDelegate.thumbnailPath ? Qt.resolvedUrl(wallpaperDelegate.thumbnailPath) : ""
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            opacity: delegateMouseArea.containsMouse ? 0.8 : 1

                            Behavior on opacity {
                                enabled: Appearance.animationsEnabled
                                NumberAnimation { duration: 100 }
                            }
                        }

                        MouseArea {
                            id: delegateMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (wallpaperDelegate.filePath) {
                                    Wallpapers.select(wallpaperDelegate.filePath, Appearance.m3colors.darkmode)
                                }
                            }
                        }

                        StyledToolTip {
                            text: wallpaperDelegate.fileName
                            visible: delegateMouseArea.containsMouse
                        }
                    }
                }
            }
        }
    }
}
