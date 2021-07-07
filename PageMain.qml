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
        gradient: Gradient {
            GradientStop { position: 0; color: "#af9090" }
            GradientStop { position: 1; color: "#605050" }
        }
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
                text: "Play"
                enabled: mp.playbackState!=MediaPlayer.PlayingState
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
        }
    }

    function selectMediaFile() {
        ms.startSelector()
    }

    MediaSelector {
        id: ms

        onFileSelected: {
            mp.source=src;
            mp.pause();
            mainPage.forceActiveFocus();
            hs.setClips(1)
        }
    }

    Keys.onEscapePressed: {
        mp.stop();
    }

    Keys.onLeftPressed: {
        mp.seek(0)

    }

    Keys.onRightPressed: {
        mp.play();
    }

    Keys.onSpacePressed: {
        console.debug("SPACE")
        if (mp.playbackState==MediaPlayer.PlayingState)
            mp.pause();
        else
            mp.play();
    }

    VideoOutput {
        id: vo
        anchors.fill: parent
        source: mp
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            fullScreen=!fullScreen
            mainPage.forceActiveFocus();
        }
    }

    MediaPlayer {
        id: mp
        // source: ""
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
    }
}


