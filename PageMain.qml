import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12
import QtMultimedia 5.12

import org.tal.hyperhyper 1.0

Page {
    id: mainPage
    objectName: "main"
    focus: true

    property bool fullScreen: false

    background: Rectangle {
        color: bgBlack.checked ? "black" : "green"
    }

    Drawer {
        id: playlistDrawer
        height: root.height
        width: root.width/3
        dragMargin: rootStack.depth > 1 ? 0 : Qt.styleHints.startDragDistance
        enabled: !fullScreen
        ColumnLayout {
            anchors.fill: parent
            ListView {
                Layout.fillHeight: true
                Layout.fillWidth: true
                visible: !fullScreen
                model: plist
                clip: true
                delegate: Row {
                    Text {
                        text: source
                    }
                }
                ScrollIndicator.vertical: ScrollIndicator { }
            }
        }
    }

    header: MenuBar {
        visible: !fullScreen
        Menu {
            title: "File"

            MenuItem {
                text: "Add..."
                onClicked: {
                    ms.startSelector()
                }
            }

            MenuItem {
                text: "Open..."
                onClicked: {
                    plist.load("file:///tmp/playlist.m3u8", "m3u8")
                }
            }

            MenuItem {
                text: "Save..."
                onClicked: {
                    plist.save("file:///tmp/playlist.m3u8", "m3u8")
                }
            }

            MenuItem {
                text: "Clear"
                onClicked: {
                    plist.clear()
                }
            }

            MenuSeparator {

            }

            MenuItem {
                text: "Quit"
                onClicked: {
                    Qt.quit()
                }
            }
        }
        Menu {
            title: "Background"

            MenuItem {
                id: bgBlack
                text: "Black"
                checkable: true
            }
        }
    }

    footer: ToolBar {
        visible: !fullScreen
        RowLayout {
            anchors.fill: parent
            Label {
                id: conMsg
                text: mp.errorString
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft
            }
            Label {
                id: bufMsg
                text: mp.bufferProgress
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft
            }
            Label {
                id: itemsMsg
                text: 1+plist.currentIndex+"/"+plist.itemCount
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft
            }
            ToolButton {
                text: "Play"
                enabled: mp.playbackState!=MediaPlayer.PlayingState && mp.status!=MediaPlayer.NoMedia
                onClicked: {
                    mp.play();
                }
            }
            ToolButton {
                text: "Pause"
                enabled: mp.playbackState==MediaPlayer.PlayingState
                onClicked: {
                    mp.pause()
                }
            }
            ToolButton {
                text: "Stop"
                enabled: mp.playbackState==MediaPlayer.PlayingState
                onClicked: {
                    mp.stop();
                }
            }
            ToolButton {
                text: "Previous"
                onClicked: {
                    previousMediaFile();
                }
            }
            ToolButton {
                text: "Next"
                onClicked: {
                    nextMediaFile();
                }
            }
        }
    }

    function selectMediaFile() {
        ms.startSelector()
    }

    function nextMediaFile() {
        plist.playbackMode=Playlist.Sequential
        plist.next();
        mp.pause();
        plist.playbackMode=Playlist.CurrentItemOnce
    }

    function previousMediaFile() {
        plist.playbackMode=Playlist.Sequential
        plist.previous();
        mp.pause();
        plist.playbackMode=Playlist.CurrentItemOnce
    }

    MediaSelector {
        id: ms

        onFileSelected: {
            plist.addItem(src)
            mp.pause();
            mainPage.forceActiveFocus();
            hs.setClips(plist.itemCount)
        }

        onFilesSelected: {
            plist.addItems(src)
            mainPage.forceActiveFocus();
            hs.setClips(plist.itemCount)
        }
    }

    Keys.onEscapePressed: {
        mp.stop();
    }
    Keys.onLeftPressed: {
        console.debug("Left")
        plist.previous();
    }
    Keys.onRightPressed: {
        console.debug("Right")
        plist.next()
    }
    Keys.onDigit1Pressed: {
        plist.currentIndex=0;
    }
    Keys.onDigit2Pressed: {
        plist.currentIndex=1;
    }
    Keys.onDigit3Pressed: {
        plist.currentIndex=2;
    }
    Keys.onDigit0Pressed: {
        plist.shuffle();
    }

    Keys.onSpacePressed: {
        console.debug("SPACE")
        if (mp.playbackState==MediaPlayer.PlayingState)
            mp.pause();
        else
            mp.play();
    }

    ColumnLayout {
        anchors.fill: parent
        VideoOutput {
            id: vo
            source: mp
            Layout.fillHeight: true
            Layout.fillWidth: true
            autoOrientation: true

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    fullScreen=!fullScreen
                    mainPage.forceActiveFocus();
                }
            }
        }

    }

    MediaPlayer {
        id: mp
        playlist: plist
        autoLoad: true
        loops: 1 // hs.loops
        // playbackRate: hs.speed/100
        onPlaying: {
            hs.setStatus("playing")
        }
        onStopped: {
            hs.setStatus("stopped")
        }
        onPaused: {
            hs.setStatus("stopped")
        }
        onPositionChanged: {
            hs.setTimecode(position);
        }
        onDurationChanged: {
            hs.setDuration(duration)
        }

        onStatusChanged: console.debug(status)
    }

    Playlist {
        id: plist
        playbackMode: Playlist.CurrentItemOnce
        onLoaded: {
            console.debug("Playlist loaded: "+itemCount)
        }
        onLoadFailed: {
            console.debug(errorString)
        }        
    }

    HyperServer {
        id: hs        
        onPlay: {
            console.debug("PLAY")
            mp.play();
        }
        onRecord: {
            console.debug("RECORD")
            hs.setStatus("stopped")
        }
        onStop: {
            console.debug("STOP")
            mp.stop();
        }
        onLoopChanged: {
            if (loop>1) {
                plist.playbackMode=Playlist.CurrentItemInLoop
            } else {
                plist.playbackMode=Playlist.CurrentItemOnce
            }
        }
    }
}


