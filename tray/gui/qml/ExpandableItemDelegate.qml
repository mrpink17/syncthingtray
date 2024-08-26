import QtQml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Main

ItemDelegate {
    id: mainDelegate
    width: mainView.width
    onClicked: detailsView.visible = !detailsView.visible

    contentItem: ColumnLayout {
        RowLayout {
            Icon {
                source: modelData.statusIcon
                width: 32
                height: 32
            }
            Label {
                Layout.fillWidth: true
                text: modelData.name
            }
            QtObject {
                id: source
                property int row: modelData.index
                property int col: 0
            }
            Repeater {
                model: mainDelegate.actions
                RoundButton {
                    required property Action modelData
                    hoverEnabled: true
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    ToolTip.visible: hovered || pressed
                    ToolTip.text: modelData.text
                    ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                    icon.source: modelData.icon.source
                    icon.width: 12
                    icon.height: 12
                    onClicked: modelData.trigger(source)
                }
            }
            RoundButton {
                visible: mainDelegate.extraActions.length > 0
                hoverEnabled: true
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                ToolTip.visible: hovered || pressed
                ToolTip.text: qsTr("More actions")
                ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                icon.source: app.faUrlBase + "bars"
                icon.width: 12
                icon.height: 12
                onClicked: menu.popup()
            }
            Menu {
                id: menu
                Instantiator {
                    id: menuInstantiator
                    model: mainDelegate.extraActions
                    delegate: MenuItem {
                        required property Action modelData
                        text: modelData.text
                        onTriggered: modelData.trigger(source)
                    }
                    onObjectAdded: (index, object) => menu.insertItem(index, object)
                    onObjectRemoved: (index, object) => menu.removeItem(object)
                }
            }
        }
        DetailsListView {
            id: detailsView
            mainView: mainDelegate.mainView
        }
    }

    required property var modelData
    required property ListView mainView
    property list<Action> actions
    property list<Action> extraActions
}
