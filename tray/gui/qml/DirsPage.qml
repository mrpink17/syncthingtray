import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

StackView {
    id: stackView
    Layout.fillWidth: true
    Layout.fillHeight: true
    initialItem: Page {
        title: qsTr("Folder overview")
        Layout.fillWidth: true
        Layout.fillHeight: true
        DirListView {
            mainModel: app.dirModel
            stackView: stackView
        }
    }
}
