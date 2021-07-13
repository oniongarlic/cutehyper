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

    header: MenuBar {
        visible: !fullScreen
        Menu {
            title: "File"

            MenuItem {
                text: "Open..."
                onClicked: {
                    ms.startSelector()
                }
            }

            MenuItem {
                text: "Clear"
                onClicked: {
                    plist.clear()
                }
            }

            MenuItem {
                text: "Play"
                enabled: mp.playbackState!=MediaPlayer.PlayingState && mp.status!=MediaPlayer.NoMedia
                onClicked: {
                    mp.play();
                }
            }

            MenuItem {
                text: "Pause"
                enabled: mp.playbackState==MediaPlayer.PlayingState
                onClicked: {
                    mp.pause()
                }
            }

            MenuItem {
                text: "Stop"
                enabled: mp.playbackState==MediaPlayer.PlayingState
                onClicked: {
                    mp.stop();
                }
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
        }
    }

    function selectMediaFile() {
        ms.startSelector()
    }

    MediaSelector {
        id: ms

        onFileSelected: {
            plist.addItem(src)
            mp.pause();
            mainPage.forceActiveFocus();
            hs.setClips(1)
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

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    fullScreen=!fullScreen
                    mainPage.forceActiveFocus();
                }
            }
        }
        ListView {
            Layout.fillHeight: true
            visible: !fullScreen
            model: plist
            delegate: Text {
                text: source
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


