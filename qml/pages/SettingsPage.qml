import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: settingsPage
    orientation: Orientation.Portrait

    DataBase {
        id: database
    }

    Component.onCompleted: {
        database.initDatabase()
        var currencyIndex = database.getValue("currency")
        if (currencyIndex) {
            currency.currentIndex = currencyIndex
        } else {
            database.storeData("currency", 1, "EUR")
        }
        var languageIndex = database.getValue("language")
        if (languageIndex) {
            language.currentIndex = languageIndex
        } else {
            database.storeData("language", 0, "EN")
        }
        var convert = database.getName("convert")
        if (convert) {
            if (convert == "false") {
                convertPrice.checked = false
            } else {
                convertPrice.checked = true
            }
        } else {
            database.storeData("convert", "false", "false")
        }

        var showHints = database.getName("hints")
        if (showHints) {
            if (showHints == "false") {
                hints.checked = false
            } else {
                hints.checked = true
            }
        } else {
            database.storeData("hints", "true", "true")
            hints.checked = true
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: Theme.horizontalPageMargin

        SectionHeader {
            text: qsTr("Search settings")
        }
        ComboBox {
            id: language
            width: parent.width
            anchors {
                left: parent.left
                leftMargin: Theme.paddingMedium
            }

            label: qsTr("Language")

            menu: ContextMenu {
                MenuItem { text: qsTr("EN") }
                MenuItem { text: qsTr("RU") }
                MenuItem { text: qsTr("DE") }
                MenuItem { text: qsTr("FR") }
                MenuItem { text: qsTr("IT") }
                MenuItem { text: qsTr("PL") }
                MenuItem { text: qsTr("TH") }
            }
            onCurrentIndexChanged: {
                database.storeData("language", language.currentIndex, language.value)
            }
        }
        TextSwitch {
            id: convertPrice
            text: qsTr("Convert price to")
            onCheckedChanged: {
                if (checked) {
                    database.storeData("convert", "true", "true")
                } else {
                    database.storeData("convert", "false", "false")
                }
            }
        }

        ComboBox {
            id: currency
            width: parent.width
            enabled: convertPrice.checked
            anchors {
                left: parent.left
                leftMargin: Theme.paddingMedium
            }

            label: qsTr("Currency")

            menu: ContextMenu {
                MenuItem { text: qsTr("USD") }
                MenuItem { text: qsTr("EUR") }
                MenuItem { text: qsTr("RUB") }
            }
            onCurrentIndexChanged: {
                database.storeData("currency", currency.currentIndex, currency.value)
            }
        }
        SectionHeader {
            text: qsTr("Application settings")
        }
        TextSwitch {
            id: hints
            text: qsTr("Show hints")
            onCheckedChanged: {
                if (checked) {
                    database.storeData("hints", "true", "true")
                } else {
                    database.storeData("hints", "false", "false")
                }
            }
        }
    }

}
