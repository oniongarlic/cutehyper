import QtQuick 2.15
import QtQuick.Window 2.15
import QtMultimedia 5.15

Window {
    id: videoWindow
    width: 1280
    height: 768
    visible: true
    visibility: Window.Windowed
    screen: Qt.application.screens[1] // xxx
    color: "green"

    readonly property VideoOutput vo: vo        

    VideoOutput {
        id: vo
        source: mp
        anchors.fill: parent
        autoOrientation: true

        MouseArea {
            anchors.fill: parent
            onDoubleClicked: {
                videoWindow.visibility=videoWindow.visibility==Window.Windowed ? Window.FullScreen : Window.Windowed
            }
        }
    }
}
