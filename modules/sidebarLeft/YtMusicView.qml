pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Qt5Compat.GraphicalEffects as GE
import Quickshell
import Quickshell.Io
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.modules.common.models
import qs.services

/**
 * YT Music panel - Premium Edition
 * Features: Full Player Overlay, Glassmorphism, Sync Cache, Smooth Animations.
 */
Item {
    id: root

    readonly property bool isAvailable: YtMusic.available
    readonly property bool hasQueue: YtMusic.queue.length > 0
    readonly property bool isPlaying: YtMusic.isPlaying
    readonly property bool hasTrack: YtMusic.currentVideoId !== ""

    // Views: "home", "search", "library", "account"
    property string currentView: "home"
    property bool showFullPlayer: false

    function openCreatePlaylist() { createPlaylistDialog.open() }
    function openAddToPlaylist(item) { 
        globalAddToPlaylistPopup.targetItem = item
        globalAddToPlaylistPopup.open() 
    }

    // Adaptive colors
    ColorQuantizer {
        id: colorQuantizer
        source: YtMusic.currentThumbnail
        depth: 0
        rescaleSize: 1
    }

    property color artColor: ColorUtils.mix(
        colorQuantizer?.colors[0] ?? Appearance.colors.colPrimary,
        Appearance.colors.colPrimaryContainer, 0.7
    )
    property QtObject blendedColors: AdaptedMaterialScheme { color: root.artColor }

    // Quad-Style theming
    readonly property color colText: Appearance.inirEverywhere ? Appearance.inir.colText : Appearance.colors.colOnLayer0
    readonly property color colTextSecondary: Appearance.inirEverywhere ? Appearance.inir.colTextSecondary : Appearance.colors.colSubtext
    readonly property color colPrimary: Appearance.inirEverywhere ? Appearance.inir.colPrimary : Appearance.colors.colPrimary
    readonly property color colSurface: Appearance.inirEverywhere ? Appearance.inir.colLayer1
                                      : Appearance.auroraEverywhere ? "transparent" : Appearance.colors.colLayer1
    readonly property color colSurfaceHover: Appearance.inirEverywhere ? Appearance.inir.colLayer1Hover
                                           : Appearance.auroraEverywhere ? Appearance.aurora.colSubSurface
                                           : Appearance.colors.colLayer1Hover
    readonly property color colLayer2: Appearance.inirEverywhere ? Appearance.inir.colLayer2
                                     : Appearance.auroraEverywhere ? Appearance.aurora.colSubSurface
                                     : Appearance.colors.colLayer2
    readonly property color colLayer2Hover: Appearance.inirEverywhere ? Appearance.inir.colLayer2Hover
                                          : Appearance.auroraEverywhere ? Appearance.aurora.colSubSurfaceHover
                                          : Appearance.colors.colLayer2Hover
    readonly property color colBorder: Appearance.inirEverywhere ? Appearance.inir.colBorder : "transparent"
    readonly property int borderWidth: Appearance.inirEverywhere ? 1 : 0
    readonly property real radiusSmall: Appearance.inirEverywhere ? Appearance.inir.roundingSmall : Appearance.rounding.small
    readonly property real radiusNormal: Appearance.inirEverywhere ? Appearance.inir.roundingNormal : Appearance.rounding.normal

    // Visualizer
    property list<real> visualizerPoints: []
    Process {
        id: cavaProc
        running: root.visible && root.isPlaying && GlobalStates.sidebarLeftOpen
        onRunningChanged: { if (!running) root.visualizerPoints = [] }
        command: ["cava", "-p", `${FileUtils.trimFileProtocol(Directories.scriptPath)}/cava/raw_output_config.txt`]
        stdout: SplitParser {
            onRead: data => {
                root.visualizerPoints = data.split(";").map(p => parseFloat(p.trim())).filter(p => !isNaN(p))
            }
        }
    }

    // === MAIN LAYOUT ===
    Item {
        anchors.fill: parent
        
        // Content Container
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10
            visible: !root.showFullPlayer
            opacity: visible ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }

            // Header / Nav
            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                Repeater {
                    model: [
                        { id: "home", icon: "home", label: Translation.tr("Home") },
                        { id: "search", icon: "search", label: Translation.tr("Search") },
                        { id: "library", icon: "library_music", label: Translation.tr("Library") },
                        { id: "account", icon: YtMusic.googleConnected ? "account_circle" : "person_off", label: Translation.tr("Account") }
                    ]

                    RippleButton {
                        required property var modelData
                        Layout.fillWidth: true
                        implicitHeight: 40
                        buttonRadius: root.radiusSmall
                        colBackground: root.currentView === modelData.id ? root.colPrimary : "transparent"
                        colBackgroundHover: root.currentView === modelData.id ? root.colPrimary : root.colLayer2Hover
                        onClicked: root.currentView = modelData.id

                        contentItem: ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 2
                            MaterialSymbol {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.icon
                                iconSize: 20
                                color: root.currentView === modelData.id ? Appearance.colors.colOnPrimary : root.colTextSecondary
                            }
                        }
                    }
                }
            }

            // View Stack
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                StackLayout {
                    anchors.fill: parent
                    currentIndex: ["home", "search", "library", "account"].indexOf(root.currentView)
                    
                    HomeView {}
                    SearchView {}
                    LibraryView {}
                    AccountView {}
                }
            }

            // Mini Player
            Loader {
                Layout.fillWidth: true
                active: root.hasTrack
                visible: active
                
                sourceComponent: Rectangle {
                    implicitHeight: 72
                    radius: root.radiusNormal
                    color: Appearance.inirEverywhere ? Appearance.inir.colLayer1 
                         : Appearance.auroraEverywhere ? ColorUtils.transparentize(root.blendedColors?.colLayer0 ?? Appearance.colors.colLayer0, 0.6)
                         : (root.blendedColors?.colLayer0 ?? Appearance.colors.colLayer0)
                    border.width: root.borderWidth
                    border.color: root.colBorder
                    clip: true

                    // Background Art Blur
                    Image {
                        anchors.fill: parent
                        source: YtMusic.currentThumbnail
                        fillMode: Image.PreserveAspectCrop
                        opacity: 0.3
                        visible: opacity > 0
                        layer.enabled: Appearance.effectsEnabled
                        layer.effect: MultiEffect { blurEnabled: true; blur: 0.5; blurMax: 32; saturation: 0.2 }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.showFullPlayer = true
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 10

                        // Art
                        Rectangle {
                            Layout.preferredWidth: 56
                            Layout.preferredHeight: 56
                            radius: root.radiusSmall
                            color: "black"
                            clip: true
                            Image {
                                anchors.fill: parent
                                source: YtMusic.currentThumbnail
                                fillMode: Image.PreserveAspectCrop
                            }
                        }

                        // Info
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            StyledText {
                                Layout.fillWidth: true
                                text: YtMusic.currentTitle
                                font.weight: Font.Bold
                                elide: Text.ElideRight
                                color: root.colText
                            }
                            StyledText {
                                Layout.fillWidth: true
                                text: YtMusic.currentArtist
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: root.colTextSecondary
                                elide: Text.ElideRight
                            }
                        }

                        // Controls
                        RippleButton {
                            implicitWidth: 32; implicitHeight: 32
                            buttonRadius: 16
                            colBackground: "transparent"
                            onClicked: YtMusic.togglePlaying()
                            contentItem: MaterialSymbol {
                                anchors.centerIn: parent
                                text: YtMusic.isPlaying ? "pause" : "play_arrow"
                                iconSize: 24
                                color: root.colText
                            }
                        }
                        
                        RippleButton {
                            implicitWidth: 32; implicitHeight: 32
                            buttonRadius: 16
                            colBackground: "transparent"
                            onClicked: YtMusic.playNext()
                            contentItem: MaterialSymbol {
                                anchors.centerIn: parent
                                text: "skip_next"
                                iconSize: 24
                                color: root.colText
                            }
                        }
                    }
                    
                    // Progress Bar (Bottom)
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        height: 2
                        width: parent.width * (YtMusic.currentDuration > 0 ? YtMusic.currentPosition / YtMusic.currentDuration : 0)
                        color: root.colPrimary
                    }
                }
            }
        }

        // === FULL PLAYER OVERLAY ===
        Rectangle {
            id: fullPlayer
            anchors.fill: parent
            color: Appearance.inirEverywhere ? Appearance.inir.colLayer0 
                 : (root.blendedColors?.colLayer0 ?? Appearance.colors.colLayer0)
            visible: root.showFullPlayer
            opacity: visible ? 1 : 0
            
            // Slide up animation
            transform: Translate {
                y: root.showFullPlayer ? 0 : parent.height
                Behavior on y { NumberAnimation { duration: 300; easing.type: Easing.OutQuart } }
            }
            
            // Background Art (Full Blur)
            Image {
                anchors.fill: parent
                source: YtMusic.currentThumbnail
                fillMode: Image.PreserveAspectCrop
                opacity: 0.4
                visible: opacity > 0
                layer.enabled: Appearance.effectsEnabled
                layer.effect: MultiEffect { blurEnabled: true; blur: 1.0; blurMax: 64; saturation: 0.4 }
            }
            
            // Content
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                // Header
                RowLayout {
                    Layout.fillWidth: true
                    RippleButton {
                        implicitWidth: 40; implicitHeight: 40
                        buttonRadius: 20
                        colBackground: "transparent"
                        colBackgroundHover: ColorUtils.transparentize("white", 0.1)
                        onClicked: root.showFullPlayer = false
                        contentItem: MaterialSymbol { anchors.centerIn: parent; text: "keyboard_arrow_down"; iconSize: 28; color: root.colText }
                    }
                    Item { Layout.fillWidth: true }
                    StyledText { text: Translation.tr("Now Playing"); font.weight: Font.Bold; color: root.colTextSecondary }
                    Item { Layout.fillWidth: true }
                    RippleButton {
                        implicitWidth: 40; implicitHeight: 40
                        buttonRadius: 20
                        colBackground: "transparent"
                        colBackgroundHover: ColorUtils.transparentize("white", 0.1)
                        onClicked: root.openAddToPlaylist({
                            videoId: YtMusic.currentVideoId,
                            title: YtMusic.currentTitle,
                            artist: YtMusic.currentArtist,
                            duration: YtMusic.currentDuration
                        })
                        contentItem: MaterialSymbol { anchors.centerIn: parent; text: "playlist_add"; iconSize: 24; color: root.colText }
                    }
                }
                
                // Big Art
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    Rectangle {
                        anchors.centerIn: parent
                        width: Math.min(parent.width, parent.height)
                        height: width
                        radius: root.radiusNormal
                        color: "black"
                        clip: true
                        
                        StyledRectangularShadow { target: parent; visible: true; opacity: 0.5 }
                        
                        Image {
                            anchors.fill: parent
                            source: YtMusic.currentThumbnail
                            fillMode: Image.PreserveAspectCrop
                        }
                    }
                }
                
                // Info
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    StyledText {
                        Layout.fillWidth: true
                        text: YtMusic.currentTitle
                        font.pixelSize: Appearance.font.pixelSize.large
                        font.weight: Font.Bold
                        color: root.colText
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }
                    StyledText {
                        Layout.fillWidth: true
                        text: YtMusic.currentArtist
                        font.pixelSize: Appearance.font.pixelSize.normal
                        color: root.colTextSecondary
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }
                }
                
                // Visualizer
                WaveVisualizer {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    live: YtMusic.isPlaying
                    points: root.visualizerPoints
                    maxVisualizerValue: 1000
                    smoothing: 2
                    color: root.colPrimary
                }
                
                // Progress
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    
                    StyledSlider {
                        Layout.fillWidth: true
                        from: 0
                        to: YtMusic.currentDuration > 0 ? YtMusic.currentDuration : 1
                        value: YtMusic.currentPosition
                        onMoved: YtMusic.seek(value)
                        highlightColor: root.colPrimary
                        handleColor: root.colText
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        StyledText { text: StringUtils.friendlyTimeForSeconds(YtMusic.currentPosition); color: root.colTextSecondary; font.pixelSize: 12 }
                        Item { Layout.fillWidth: true }
                        StyledText { text: StringUtils.friendlyTimeForSeconds(YtMusic.currentDuration); color: root.colTextSecondary; font.pixelSize: 12 }
                    }
                }
                
                // Controls
                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 20
                    
                    Item { Layout.fillWidth: true }
                    
                    RippleButton {
                        implicitWidth: 48; implicitHeight: 48; buttonRadius: 24
                        colBackground: "transparent"
                        onClicked: YtMusic.shuffleQueue()
                        contentItem: MaterialSymbol { anchors.centerIn: parent; text: "shuffle"; iconSize: 24; color: root.colTextSecondary }
                    }
                    
                    RippleButton {
                        implicitWidth: 56; implicitHeight: 56; buttonRadius: 28
                        colBackground: "transparent"
                        enabled: false // Previous not supported well
                        opacity: 0.5
                        contentItem: MaterialSymbol { anchors.centerIn: parent; text: "skip_previous"; iconSize: 32; color: root.colText; fill: 1 }
                    }
                    
                    RippleButton {
                        implicitWidth: 72; implicitHeight: 72; buttonRadius: 36
                        colBackground: root.colPrimary
                        onClicked: YtMusic.togglePlaying()
                        contentItem: MaterialSymbol { 
                            anchors.centerIn: parent
                            text: YtMusic.isPlaying ? "pause" : "play_arrow"
                            iconSize: 40
                            color: Appearance.colors.colOnPrimary
                            fill: 1
                        }
                    }
                    
                    RippleButton {
                        implicitWidth: 56; implicitHeight: 56; buttonRadius: 28
                        colBackground: "transparent"
                        onClicked: YtMusic.playNext()
                        contentItem: MaterialSymbol { anchors.centerIn: parent; text: "skip_next"; iconSize: 32; color: root.colText; fill: 1 }
                    }
                    
                    RippleButton {
                        implicitWidth: 48; implicitHeight: 48; buttonRadius: 24
                        colBackground: "transparent"
                        onClicked: root.currentView = "queue"; // Show queue
                        contentItem: MaterialSymbol { anchors.centerIn: parent; text: "queue_music"; iconSize: 24; color: root.colTextSecondary }
                    }
                    
                    Item { Layout.fillWidth: true }
                }
                
                Item { Layout.preferredHeight: 20 }
            }
        }
    }

    // === SUB-COMPONENTS ===

    component HomeView: ColumnLayout {
        spacing: 12

        // Welcome / Status
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            Rectangle {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                radius: 20
                color: root.colLayer2
                clip: true
                
                MaterialSymbol {
                    anchors.centerIn: parent
                    text: "face"
                    iconSize: 24
                    color: root.colTextSecondary
                }
            }
            
            ColumnLayout {
                spacing: 0
                StyledText {
                    text: Translation.tr("Welcome back")
                    font.weight: Font.Bold
                    color: root.colText
                }
                StyledText {
                    text: YtMusic.googleConnected ? Translation.tr("Connected") : Translation.tr("Guest")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: root.colTextSecondary
                }
            }
            
            Item { Layout.fillWidth: true }
            
            RippleButton {
                implicitWidth: 36; implicitHeight: 36
                buttonRadius: 18
                colBackground: root.colLayer2
                onClicked: YtMusic.fetchLibrary()
                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: "refresh"
                    iconSize: 20
                    color: root.colText
                    RotationAnimation on rotation {
                        from: 0; to: 360; duration: 1000; loops: Animation.Infinite; running: YtMusic.libraryLoading
                    }
                }
            }
        }

        // Quick Mixes (Hardcoded useful links)
        StyledText { text: Translation.tr("Quick Mixes"); font.weight: Font.Bold; color: root.colText }
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Repeater {
                model: [
                    { name: "Supermix", icon: "auto_awesome", url: "https://music.youtube.com/playlist?list=RDTMAK5uy_kset8DisdE7LSD4VsHj8J-c_xd_lzLE" },
                    { name: "Discover", icon: "explore", url: "https://music.youtube.com/playlist?list=RDTMAK5uy_n41zQj7g_k_1-2-3-4-5" } // Generic discovery
                ]
                
                RippleButton {
                    Layout.fillWidth: true
                    implicitHeight: 50
                    buttonRadius: root.radiusSmall
                    colBackground: root.colLayer2
                    colBackgroundHover: root.colLayer2Hover
                    onClicked: YtMusic.importYtMusicPlaylist(modelData.url)
                    
                    contentItem: RowLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        MaterialSymbol { text: modelData.icon; color: root.colPrimary }
                        StyledText { text: modelData.name; font.weight: Font.Medium; color: root.colText }
                    }
                }
            }
        }

        // Liked Songs Quick Access
        RippleButton {
            Layout.fillWidth: true
            implicitHeight: 60
            buttonRadius: root.radiusNormal
            colBackground: root.colLayer2
            colBackgroundHover: root.colLayer2Hover
            onClicked: {
                if (YtMusic.cloudLiked.length > 0) {
                    YtMusic.queue = YtMusic.cloudLiked
                    YtMusic.play(YtMusic.cloudLiked[0])
                } else {
                    YtMusic.fetchLikedSongs()
                }
            }

            contentItem: RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 12
                
                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    radius: 4
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#4a00e0" }
                        GradientStop { position: 1.0; color: "#8e2de2" }
                    }
                    MaterialSymbol { anchors.centerIn: parent; text: "favorite"; color: "white"; iconSize: 20; fill: 1 }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    StyledText { text: Translation.tr("Liked Songs"); font.weight: Font.Bold; color: root.colText }
                    StyledText { 
                        text: YtMusic.cloudLiked.length + " " + Translation.tr("songs")
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: root.colTextSecondary 
                    }
                }
                
                MaterialSymbol { text: "play_circle"; iconSize: 32; color: root.colPrimary; fill: 1 }
            }
        }

        // Recent Searches / History
        StyledText {
            text: Translation.tr("Recently Played")
            font.weight: Font.Bold
            color: root.colText
            visible: YtMusic.recentSearches.length > 0
        }

        ListView {
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            visible: YtMusic.recentSearches.length > 0
            orientation: ListView.Horizontal
            clip: true
            spacing: 8
            model: YtMusic.recentSearches
            
            delegate: RippleButton {
                width: 100
                height: 100
                buttonRadius: root.radiusNormal
                colBackground: root.colLayer2
                colBackgroundHover: root.colLayer2Hover
                onClicked: YtMusic.search(modelData)
                
                contentItem: ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    MaterialSymbol {
                        Layout.alignment: Qt.AlignHCenter
                        text: "history"
                        iconSize: 32
                        color: root.colPrimary
                    }
                    StyledText {
                        Layout.fillWidth: true
                        text: modelData
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: root.colText
                    }
                }
            }
        }
        
        Item { Layout.fillHeight: true }
    }

    component LibraryView: ColumnLayout {
        spacing: 0
        
        // Tabs
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 4
            spacing: 8
            
            property string tab: "playlists" // playlists, albums
            
            Repeater {
                model: ["playlists", "albums"]
                RippleButton {
                    Layout.fillWidth: true
                    implicitHeight: 32
                    buttonRadius: 16
                    colBackground: parent.tab === modelData ? root.colText : "transparent"
                    onClicked: parent.tab = modelData
                    
                    contentItem: StyledText {
                        anchors.centerIn: parent
                        text: modelData === "playlists" ? Translation.tr("Playlists") : Translation.tr("Albums")
                        color: parent.parent.tab === modelData ? root.colSurface : root.colText
                        font.weight: Font.Medium
                    }
                }
            }
        }
        
        // Content
        Loader {
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceComponent: parent.children[0].tab === "playlists" ? playlistsComp : albumsComp
        }
        
        Component {
            id: playlistsComp
            ListView {
                clip: true
                model: YtMusic.cloudPlaylists
                spacing: 4
                
                // Empty State
                visible: count > 0 || YtMusic.libraryLoading
                
                header: Loader {
                    active: YtMusic.libraryLoading
                    sourceComponent: RowLayout {
                        width: parent.width
                        height: 40
                        Item { Layout.fillWidth: true }
                        BusyIndicator { implicitWidth: 24; implicitHeight: 24; running: true }
                        Item { Layout.fillWidth: true }
                    }
                }

                delegate: RippleButton {
                    width: ListView.view.width
                    implicitHeight: 60
                    buttonRadius: root.radiusSmall
                    colBackground: "transparent"
                    colBackgroundHover: root.colLayer2Hover
                    onClicked: YtMusic.importYtMusicPlaylist(modelData.url)
                    
                    contentItem: RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 12
                        
                        Rectangle {
                            Layout.preferredWidth: 44
                            Layout.preferredHeight: 44
                            radius: 4
                            color: root.colLayer2
                            MaterialSymbol { anchors.centerIn: parent; text: "queue_music"; color: root.colTextSecondary }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            StyledText { 
                                text: modelData.title
                                font.weight: Font.Medium
                                color: root.colText
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            StyledText { 
                                text: modelData.count + " tracks"
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: root.colTextSecondary
                            }
                        }
                        
                        MaterialSymbol { text: "play_arrow"; color: root.colTextSecondary }
                    }
                }
            }
        }
        
        Component {
            id: albumsComp
            GridView {
                clip: true
                cellWidth: width / 2
                cellHeight: cellWidth + 40
                model: YtMusic.cloudAlbums
                
                delegate: Item {
                    width: GridView.view.cellWidth
                    height: GridView.view.cellHeight
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 6
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: width
                            radius: root.radiusSmall
                            color: root.colLayer2
                            clip: true
                            
                            MaterialSymbol { anchors.centerIn: parent; text: "album"; iconSize: 32; color: root.colTextSecondary }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: YtMusic.importYtMusicPlaylist(modelData.url)
                            }
                        }
                        
                        StyledText {
                            Layout.fillWidth: true
                            text: modelData.title
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                            color: root.colText
                        }
                    }
                }
            }
        }
    }

    component SearchView: ColumnLayout {
        spacing: 10
        
        TextField {
            Layout.fillWidth: true
            placeholderText: Translation.tr("Search songs, artists...")
            color: root.colText
            placeholderTextColor: root.colTextSecondary
            background: Rectangle {
                color: root.colLayer2
                radius: root.radiusSmall
                border.width: 1
                border.color: parent.activeFocus ? root.colPrimary : "transparent"
            }
            onAccepted: YtMusic.search(text)
        }
        
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: YtMusic.searchResults
            spacing: 4
            
            delegate: RippleButton {
                width: ListView.view.width
                implicitHeight: 56
                buttonRadius: root.radiusSmall
                colBackground: "transparent"
                colBackgroundHover: root.colLayer2Hover
                onClicked: YtMusic.play(modelData)
                
                contentItem: RowLayout {
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 10
                    
                    Image {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 44
                        source: modelData.thumbnail
                        fillMode: Image.PreserveAspectCrop
                        layer.enabled: true
                        layer.effect: GE.OpacityMask { maskSource: Rectangle { width: 44; height: 44; radius: 4 } }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        StyledText { text: modelData.title; font.weight: Font.Medium; color: root.colText; elide: Text.ElideRight; Layout.fillWidth: true }
                        StyledText { text: modelData.artist; font.pixelSize: Appearance.font.pixelSize.smaller; color: root.colTextSecondary; elide: Text.ElideRight; Layout.fillWidth: true }
                    }
                }
            }
        }
    }

    component AccountView: ColumnLayout {
        spacing: 12
        
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 100
            radius: root.radiusNormal
            color: root.colLayer2
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16
                
                MaterialSymbol {
                    text: YtMusic.googleConnected ? "check_circle" : "error"
                    iconSize: 40
                    color: YtMusic.googleConnected ? Appearance.colors.colSuccess : Appearance.colors.colError
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    StyledText { 
                        text: YtMusic.googleConnected ? Translation.tr("Account Connected") : Translation.tr("Not Connected")
                        font.weight: Font.Bold
                        font.pixelSize: Appearance.font.pixelSize.large
                        color: root.colText
                    }
                    StyledText {
                        text: YtMusic.googleConnected 
                            ? Translation.tr("Using cookies from %1").arg(YtMusic.googleBrowser)
                            : Translation.tr("Select a browser to sync library")
                        color: root.colTextSecondary
                    }
                }
            }
        }
        
        // Browser Grid (Only if not connected)
        GridLayout {
            visible: !YtMusic.googleConnected
            Layout.fillWidth: true
            columns: 3
            rowSpacing: 8
            columnSpacing: 8
            
            Repeater {
                model: YtMusic.detectedBrowsers
                RippleButton {
                    Layout.fillWidth: true
                    implicitHeight: 80
                    buttonRadius: root.radiusNormal
                    colBackground: root.colLayer2
                    colBackgroundHover: root.colLayer2Hover
                    onClicked: YtMusic.connectGoogle(modelData)
                    
                    contentItem: ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        StyledText { text: YtMusic.browserInfo[modelData]?.icon ?? "🌐"; font.pixelSize: 24 }
                        StyledText { text: YtMusic.browserInfo[modelData]?.name ?? modelData; color: root.colText }
                    }
                }
            }
        }
        
        RippleButton {
            visible: YtMusic.googleConnected
            Layout.fillWidth: true
            implicitHeight: 40
            buttonRadius: root.radiusSmall
            colBackground: ColorUtils.transparentize(Appearance.colors.colError, 0.9)
            onClicked: YtMusic.disconnectGoogle()
            contentItem: RowLayout {
                anchors.centerIn: parent
                MaterialSymbol { text: "logout"; color: Appearance.colors.colError }
                StyledText { text: Translation.tr("Disconnect"); color: Appearance.colors.colError }
            }
        }
        
        Item { Layout.fillHeight: true }
    }
}
