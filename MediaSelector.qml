import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.12

Item {
    id: igs

    signal fileSelected(string src);
    signal filesSelected(var src);

    function startSelector() {
        filesDialog.open();
    }

    FileDialog {
        id: filesDialog
        folder: shortcuts.pictures
        nameFilters: [ "*.mp4", "*.mov", "*.mp3", "*.avi" ]
        title: qsTr("Select media file(s)")
        selectExisting: true
        selectFolder: false
        selectMultiple: true
        onAccepted: {
            // XXX: Need to convert to string, otherwise sucka
            if (fileUrl!="") {
                var f=""+fileUrl
                fileSelected(f);
            } else {
                console.debug(fileUrls)
                filesSelected(fileUrls)
            }
        }
    }
}
