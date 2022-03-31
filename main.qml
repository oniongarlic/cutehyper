import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtMultimedia 5.15
import QtQuick.Controls 2.15

import org.tal.hyperhyper 1.0

ApplicationWindow {
    id: root
    width: 800
    height: 480
    visible: true
    title: qsTr("CuteHyper - Hyperdeck Emulation Test")

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

    function formatSeconds(s) {
        var h = Math.floor(s / 3600);
        s %= 3600;
        var m = Math.floor(s / 60);
        var ss = s % 60;
        return [h,m,ss].map(v => v < 10 ? "0" + v : v).join(":")
    }

    VideoWindow {
        id: videoWindow
    }

    StackView {
        id: rootStack
        anchors.fill: parent
        initialItem: mainView
        focus: true;
        onCurrentItemChanged: {
            console.debug("*** view is "+currentItem)
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

    MediaPlayer {
        id: mp
        playlist: plist
        autoLoad: true
        loops: 1 // hs.loops
        // playbackRate: hs.speed/100
        muted: mainPage.checkMuted.checked
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


    NumberAnimation {
        id: volumeFadeIn
        target: mp
        property: "name"
        duration: 1000
        easing.type: Easing.InOutQuad
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

    Component {
        id: mainView
        PageMain {
            id: mainPage
            onBgblackChanged: {
                videoWindow.color=bgblack ? "black" : "green"
            }
        }
    }
}
