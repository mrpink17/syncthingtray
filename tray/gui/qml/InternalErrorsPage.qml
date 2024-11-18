import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Main

Page {
    title: qsTr("Log of Syncthing API errors")
    Layout.fillWidth: true
    Layout.fillHeight: true
    actions: [
        Action {
            text: qsTr("Clear")
            icon.source: App.faUrlBase + "trash"
            onTriggered: (source) => {
                App.clearInternalErrors();
                listView.model = App.internalErrors();
            }
        }
    ]
    ListView {
        id: listView
        anchors.fill: parent
        activeFocusOnTab: true
        keyNavigationEnabled: true
        model: App.internalErrors()
        delegate: ErrorsDelegate {}
        ScrollIndicator.vertical: ScrollIndicator { }
    }
    Connections {
        target: App
        function onInternalError(error) {
            listView.model.push(error)
        }
    }
    property list<Action> actions
}