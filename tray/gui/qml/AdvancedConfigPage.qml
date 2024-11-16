import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs

import Main

ObjectConfigPage {
    id: advancedConfigPage
    isDangerous: true
    configTemplates: {
        "devices": {deviceID: "", introducedBy: "", encryptionPassword: ""},
        "addresses": "dynamic",
    }
    actions: [
        Action {
            text: qsTr("Apply")
            icon.source: App.faUrlBase + "check"
            onTriggered: (source) => advancedConfigPage.applyChanges()
        },
        Action {
            text: qsTr("Remove")
            icon.source: App.faUrlBase + "trash-o"
            enabled: advancedConfigPage.configObjectExists
            onTriggered: (source) => removeDialog.open()
        }
    ]

    Dialog {
        id: removeDialog
        popupType: App.nativePopups ? Popup.Native : Popup.Item
        anchors.centerIn: Overlay.overlay
        parent: Overlay.overlay
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        contentItem: ColumnLayout {
            Label {
                Layout.fillWidth: true
                text: qsTr("Do you really want to remove the %1?").arg(advancedConfigPage.entryName)
                wrapMode: Text.WordWrap
            }
            Label {
                Layout.fillWidth: true
                text: qsTr("This will only remove the %1 from Syncthing. No files will be deleted on disk.").arg(advancedConfigPage.entryName)
                wrapMode: Text.WordWrap
            }
        }
        onAccepted: advancedConfigPage.removeConfigObject()
    }

    required property string entryName
    required property string entriesKey
    required property var isEntry
    property bool configObjectExists: false

    function findConfigObject() {
        const cfg = App.connection.rawConfig;
        const entries = cfg !== undefined ? cfg[entriesKey] : undefined;
        const entry = Array.isArray(entries) ? entries.find(advancedConfigPage.isEntry) : undefined;
        return (advancedConfigPage.configObjectExists = (entry !== undefined)) ? entry : {};
    }

    function applyChanges() {
        const cfg = App.connection.rawConfig;
        const entries = cfg !== undefined ? cfg[entriesKey] : undefined;
        if (!Array.isArray(entries)) {
            return false;
        }
        advancedConfigPage.updateIdentification();
        const cfgObj = configObject;
        const index = entries.findIndex(advancedConfigPage.isEntry);
        const supposedToExist = advancedConfigPage.configObjectExists;
        if (supposedToExist && index >= 0) {
            entries[index] = cfgObj;
        } else if (!supposedToExist && index < 0) {
            entries.push(cfgObj);
        } else {
            App.showError("Can't apply, key is already used.");
            return false;
        }
        advancedConfigPage.configObjectExists = true;
        advancedConfigPage.disableInitialProperties();
        App.connection.postConfigFromJsonObject(cfg);
        return true;
    }

    function removeConfigObject() {
        const cfg = App.connection.rawConfig;
        const entries = cfg !== undefined ? cfg[entriesKey] : undefined;
        if (!Array.isArray(entries)) {
            return false;
        }
        const index = entries.findIndex(advancedConfigPage.isEntry);
        if (index < 0) {
            return false;
        }
        entries.splice(index, 1);
        advancedConfigPage.configObjectExists = false;
        App.connection.postConfigFromJsonObject(cfg);
        return true;
    }
}
