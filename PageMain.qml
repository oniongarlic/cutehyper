import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import QtMultimedia 5.12

Page {
    id: mainPage
    objectName: "main"
    focus: true

    property bool fullScreen: false
    property alias bgblack: bgBlack.checked

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
                text: "Open playlist"
                onClicked: {
                    plist.load("file:///tmp/playlist.m3u8", "m3u8")
                }
            }

            MenuItem {
                text: "Save playlist"
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
                text: 1+plist.currentIndex+" / "+plist.itemCount
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft
            }
            Label {
                id: itemTime
                text: formatSeconds(mp.position/1000)+" / "+formatSeconds(mp.duration/1000)
            }
            CheckBox {
                id: checkMuted
                text: "Mute"
                checked: mp.muted
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

    GridLayout {
        anchors.fill: parent

        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            ListView {
                Layout.fillHeight: true
                Layout.fillWidth: true
                model: plist
                clip: true
                delegate: Row {
                    spacing: 4
                    Text {
                        text: source
                    }
                }
                highlight: Rectangle { color: "#f0f0f0"; }
                ScrollIndicator.vertical: ScrollIndicator { }
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

}


