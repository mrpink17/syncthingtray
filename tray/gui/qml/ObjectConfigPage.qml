import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.qmlmodels

Page {
    id: objectConfigPage
    ListView {
        id: objectListView
        anchors.fill: parent
        ScrollIndicator.vertical: ScrollIndicator { }
        model: ListModel {
            id: listModel
            dynamicRoles: true
            Component.onCompleted: Object.entries(objectConfigPage.configObject).forEach((configEntry, index) => { listModel.append(objectConfigPage.makeConfigRow(configEntry, index)) })
        }
        delegate: DelegateChooser {
            role: "type"
            DelegateChoice {
                roleValue: "string"
                ItemDelegate {
                    width: objectListView.width
                    contentItem: RowLayout {
                        ColumnLayout {
                            Layout.fillWidth: true
                            Label {
                                Layout.fillWidth: true
                                text: modelData.label
                                elide: Text.ElideRight
                                font.weight: Font.Medium
                            }
                            Label {
                                id: stringValue
                                Layout.fillWidth: true
                                text: modelData.value
                                elide: Text.ElideRight
                                font.weight: Font.Light
                            }
                        }
                        ArrayElementButtons {
                            page: objectConfigPage
                            rowData: modelData
                        }
                        HelpButton {
                            id: helpButton
                            configCategory: objectConfigPage.configCategory
                            key: modelData.key
                        }
                    }
                    onClicked: stringDlg.visible = true
                    Dialog {
                        id: stringDlg
                        anchors.centerIn: Overlay.overlay
                        title: modelData.label
                        standardButtons: objectConfigPage.standardButtons
                        modal: true
                        width: parent.width - 20
                        contentItem: TextField {
                            id: editedStringValue
                            text: modelData.value
                            onAccepted: stringDlg.accpet()
                        }
                        onAccepted: objectConfigPage.updateValue(modelData.key, stringValue.text = editedStringValue.text)
                        onRejected: editedStringValue.text = objectConfigPage.configObject[modelData.key]
                        onHelpRequested: helpButton.clicked()
                    }
                    required property var modelData
                }
            }
            DelegateChoice {
                roleValue: "number"
                ItemDelegate {
                    width: objectListView.width
                    contentItem: RowLayout {
                        ColumnLayout {
                            Layout.fillWidth: true
                            Label {
                                Layout.fillWidth: true
                                text: modelData.label
                                elide: Text.ElideRight
                                font.weight: Font.Medium
                            }
                            Label {
                                id: numberValue
                                Layout.fillWidth: true
                                text: modelData.value
                                elide: Text.ElideRight
                                font.weight: Font.Light
                            }
                        }
                        ArrayElementButtons {
                            page: objectConfigPage
                            rowData: modelData
                        }
                        HelpButton {
                            id: numberHelpButton
                            configCategory: objectConfigPage.configCategory
                            key: modelData.key
                        }
                    }
                    onClicked: numberDlg.visible = true
                    Dialog {
                        id: numberDlg
                        anchors.centerIn: Overlay.overlay
                        title: modelData.label
                        standardButtons: objectConfigPage.standardButtons
                        modal: true
                        width: parent.width - 20
                        contentItem: TextField {
                            id: editedNumberValue
                            text: modelData.value
                            validator: DoubleValidator {
                                id: numberValidator
                                locale: "en"
                            }
                            onAccepted: numberDlg.accpet()
                        }
                        onAccepted: {
                            const number = Number.fromLocaleString(Qt.locale(numberValidator.locale), editedNumberValue.text)
                            objectConfigPage.updateValue(modelData.key, number)
                            numberValue.text = number
                        }
                        onRejected: editedNumberValue.text = objectConfigPage.configObject[modelData.key]
                        onHelpRequested: numberHelpButton.clicked()
                    }
                    required property var modelData
                }
            }
            DelegateChoice {
                roleValue: "object"
                ItemDelegate {
                    width: objectListView.width
                    contentItem: RowLayout {
                        Label {
                            id: objNameLabel
                            Layout.fillWidth: true
                            text: modelData.label
                            elide: Text.ElideRight
                            font.weight: Font.Medium
                            readonly property string key: modelData.key
                            readonly property string labelKey: modelData.labelKey
                        }
                        ArrayElementButtons {
                            page: objectConfigPage
                            rowData: modelData
                        }
                        HelpButton {
                            configCategory: objectConfigPage.configCategory
                            key: modelData.key
                        }
                    }
                    onClicked: objectConfigPage.stackView.push("ObjectConfigPage.qml", {title: objNameLabel.text, configObject: objectConfigPage.configObject[modelData.key], stackView: objectConfigPage.stackView, parentPage: objectConfigPage, objectNameLabel: objNameLabel}, StackView.PushTransition)
                    required property var modelData
                }
            }
            DelegateChoice {
                roleValue: "boolean"
                ItemDelegate {
                    width: objectListView.width
                    onClicked: booleanSwitch.toggle()
                    contentItem: RowLayout {
                        Label {
                            Layout.fillWidth: true
                            text: modelData.label
                            elide: Text.ElideRight
                            font.weight: Font.Medium
                        }
                        Switch {
                            id: booleanSwitch
                            checked: modelData.value
                            onCheckedChanged: objectConfigPage.configObject[modelData.key] = booleanSwitch.checked
                        }
                        ArrayElementButtons {
                            page: objectConfigPage
                            rowData: modelData
                        }
                        HelpButton {
                            configCategory: objectConfigPage.configCategory
                            key: modelData.key
                        }
                    }
                    required property var modelData
                }
            }
        }
    }
    Dialog {
        id: newValueDialog
        anchors.centerIn: Overlay.overlay
        title: qsTr("Add new value")
        standardButtons: Dialog.Ok | Dialog.Cancel
        modal: true
        width: parent.width - 20
        contentItem: GridLayout {
            columns: 2
            Label {
                text: Array.isArray(objectConfigPage.configObject) ? qsTr("Index") : qsTr("Key")
            }
            TextEdit {
                id: keyTextEdit
                Layout.fillWidth: true
            }
            Label {
                text: qsTr("Type")
            }
            ComboBox {
                id: typeComboBox
                model: ["String", "Number", "Boolean", "Object", "Array"]
            }
        }
        onAccepted: objectConfigPage.addObject(newValueDialog.typedKey, newValueDialog.typedValue)
        property alias key: keyTextEdit.text
        readonly property var typedKey: Array.isArray(objectConfigPage.configObject) ? Number.parseInt(newValueDialog.key) : newValueDialog.key
        readonly property var typedValue: ["", 0, false, {}, []][typeComboBox.currentIndex]
    }

    property alias model: objectListView.model
    required property var configObject
    property string configCategory
    readonly property int standardButtons: (configCategory.length > 0) ? (Dialog.Ok | Dialog.Cancel | Dialog.Help) : (Dialog.Ok | Dialog.Cancel)
    required property StackView stackView
    property Page parentPage
    property Label objectNameLabel
    property list<Action> actions: [
        Action {
            text: qsTr("Add")
            icon.source: app.faUrlBase + "plus"
            onTriggered: objectConfigPage.showNewValueDialog()
        }
    ]

    function makeConfigRow(configEntry, index) {
        const key = configEntry[0];
        const value = configEntry[1];
        const isArray = Array.isArray(objectConfigPage.configObject);
        const row = {key: key, value: value, type: typeof value, index: index, isArray: isArray};
        if (!isArray) {
            row.label = uncamel(key);
            row.labelKey = "";
        } else {
            const nestedKey = "deviceID";
            const nestedValue = value[nestedKey];
            const nestedType = typeof nestedValue;
            const hasNestedValue = nestedType === "string" || nestedType === "number";
            row.label = hasNestedValue ? nestedValue : uncamel(typeof value);
            row.labelKey = hasNestedValue ? nestedKey : "";
        }
        return row;
    }

    function updateValue(key, value) {
        objectConfigPage.configObject[key] = value
        if (Array.isArray(objectConfigPage.parentPage?.configObject) && objectConfigPage.objectNameLabel?.labelKey === key) {
            objectConfigPage.title = value
            objectConfigPage.objectNameLabel.text = value
        }
    }

    function swapObjects(modelData, moveDelta) {
        if (!modelData.isArray) {
            return;
        }
        const index = modelData.index;
        const swapIndex = index + moveDelta;
        const length = objectConfigPage.configObject.length;
        if (index >= 0 && index < length && swapIndex >= 0 && swapIndex < length) {
            const obj = objectConfigPage.configObject[index];
            const swapObj = objectConfigPage.configObject[swapIndex];
            objectConfigPage.configObject[swapIndex] = obj;
            objectConfigPage.configObject[index] = swapObj;
            listModel.move(index, swapIndex, 1);
            listModel.set(index, {index: index, key: index});
            listModel.set(swapIndex, {index: swapIndex, key: swapIndex});
        }
    }

    function removeObjects(modelData, count) {
        if (!modelData.isArray) {
            return;
        }
        const index = modelData.index;
        const length = objectConfigPage.configObject.length;
        if (index >= 0 && index < length) {
            objectConfigPage.configObject.splice(index, count);
            listModel.remove(index, count);
        }
        for (let i = index, end = listModel.count; i !== end; ++i) {
            listModel.set(i, {index: i, key: i});
        }
    }

    function addObject(key, object) {
        if (Array.isArray(objectConfigPage.configObject)) {
            const length = objectConfigPage.configObject.length;
            if (typeof key === "number" && key >= 0 && key <= length) {
                objectConfigPage.configObject.splice(key, 0, object);
                listModel.insert(key, objectConfigPage.makeConfigRow([key.toString(), object], key));
                for (let i = key + 1, end = listModel.count; i !== end; ++i) {
                    listModel.set(i, {index: i, key: i});
                }
            } else {
                app.showError(qsTr("Unable to add %1 because specified index is invalid.").arg(typeof object));
            }
        } else {
            if (typeof key === "string" && key !== "" && objectConfigPage.configObject[key] === undefined) {
                objectConfigPage.configObject[key] = object;
                listModel.append(objectConfigPage.makeConfigRow([key, object], listModel.count))
            } else {
                app.showError(qsTr("Unable to add %1 because specified key is invalid.").arg(typeof object));
            }
        }
    }

    function showNewValueDialog(key) {
        newValueDialog.key = key ?? (Array.isArray(objectConfigPage.configObject) ? objectConfigPage.configObject.length : "");
        newValueDialog.visible = true;
    }

    function uncamel(input) {
        input = input.replace(/(.)([A-Z][a-z]+)/g, '$1 $2').replace(/([a-z0-9])([A-Z])/g, '$1 $2');
        const parts = input.split(' ');
        const lastPart = parts.splice(-1)[0];
        switch (lastPart) {
        case "S":
            parts.push('(seconds)');
            break;
        case "M":
            parts.push('(minutes)');
            break;
        case "H":
            parts.push('(hours)');
            break;
        case "Ms":
            parts.push('(milliseconds)');
            break;
        default:
            parts.push(lastPart);
            break;
        }
        input = parts.join(' ');
        return input.charAt(0).toUpperCase() + input.slice(1);
    }
}
