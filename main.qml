import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.12
import QtMultimedia 5.12

import QtQuick.Controls 2.12

ApplicationWindow {
    width: 800
    height: 480
    visible: true
    title: qsTr("Hyperdeck Emulation Test")

    menuBar: MenuBar {
        Menu {
            title: "File"

            MenuItem {
                text: "Open..."
                onClicked: {

                }
            }

            MenuItem {
                text: "Play"
                onClicked: {
                    mp.play();
                }
            }

            MenuItem {
                text: "Stop"
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

    VideoOutput {
        id: vo
        anchors.fill: parent
        source: mp
    }

    MediaPlayer {
        id: mp
        source: "file:///home/milang/Videos/vj.mp4"
        autoLoad: true
        loops: 1
    }

    Connections {
        target: hyper
        onPlay: {
            mp.play()
        }

        onStop: {
            mp.stop()
        }
    }
}
