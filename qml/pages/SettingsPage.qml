import QtQuick 2.6
import Sailfish.Silica 1.0

import "../utils"
import "../delegates"

Page {
    id: settingsPage
    orientation: Orientation.Portrait

    DataBase {
        id: database
    }

    Component.onCompleted: {
        currency.currentIndex = database.getValue("currency")
        language.currentIndex = database.getValue("language")
        convertPrice.checked = database.convertCurrency
        hints.checked = database.showHints
    }

    Column {
        anchors.fill: parent

        PageHeader{
            title: qsTr("Settings")
        }
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
        IconTextItem {
            title: qsTr("Delete history")
            iconSource: "image://theme/icon-m-delete"

            onClicked: {
                database.deleteFavorites()
            }
        }
    }

}
