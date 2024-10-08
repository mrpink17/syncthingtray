import QtQuick
import QtQuick.Controls

ListView {
    id: mainView
    anchors.fill: parent
    activeFocusOnTab: true
    keyNavigationEnabled: true
    model: ExpandableDelegate {
        mainView: mainView
    }
    ScrollIndicator.vertical: ScrollIndicator { }

    required property QtObject mainModel
    property StackView stackView
}
