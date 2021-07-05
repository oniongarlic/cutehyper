import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.12

Item {
    id: igs

    signal fileSelected(string src);

    function startSelector() {
        filesDialog.open();
    }

    FileDialog {
        id: filesDialog
        folder: shortcuts.pictures
        nameFilters: [ "*.mp4", "*.mov" ]
        title: qsTr("Select image file")
        selectExisting: true
        selectFolder: false
        selectMultiple: false
        onAccepted: {
            // XXX: Need to convert to string, otherwise sucka
            var f=""+fileUrl
            fileSelected(f);
        }
    }
}
