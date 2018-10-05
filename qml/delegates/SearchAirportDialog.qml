import QtQuick 2.6
import Sailfish.Silica 1.0

import "../utils/Utils.js" as Utils
import "../utils"

Dialog {

    id: d
    property string airportName
    property string airportIATA
    property string cityIata

    onBackNavigationChanged: {
        airportsModel.clear()
    }

    DataBase {
        id: database
    }

    ListModel {
        id: airportsModel
    }

    QtObject {
        id: internal

        property bool loadData: false
        property bool finishSearching: false
    }

    function getCityInfo(data) {
        if (data !== "error") {
            var parsed = JSON.parse(data)
            if (Object.keys(parsed).length > 0) {
                airportsModel.append(parsed)
            }
        }
        internal.loadData = false
        internal.finishSearching = true
    }

    function getName(iata) {
        return airportsInfo[iata].name
    }

    Item {
        id: searchItem

        anchors.fill: parent

        SearchField {
            id: searchField
            anchors.top: parent.top
            width: parent.width
            placeholderText: qsTr('Search airports:')

            EnterKey.onClicked: {
                if(searchField.text.length > 2) {
                    airportsModel.clear()
                    var searchText = searchField.text.replace(/ /g, '%20')
                    var url = "http://nano.aviasales.ru/places_" + database.language.toLowerCase() + "?term=" + searchText
                    Utils.performRequest("GET", url, getCityInfo)
                    internal.loadData = true
                }
            }
        }
        ListView {
            clip: true
            spacing: Theme.paddingSmall
            width: parent.width
            anchors.top: searchField.bottom
            anchors.bottom: parent.bottom

            model: airportsModel
            delegate: ListItem {
                height: Theme.itemSizeSmall
                width: parent.width
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    wrapMode: Text.WordWrap
//                                visible: model.airport_name?true:false
                    text: (model.airport_name ? model.airport_name : model.name) + " (" + model.iata + ")"
                }
                onClicked: {
                    d.airportName = model.airport_name?model.airport_name:model.name
                    d.airportIATA = model.iata
                    d.cityIata = model.city_iata ? model.city_iata : model.iata
                    airportsModel.clear()
                    d.accept()
                }
            }
            ViewPlaceholder {
                enabled: airportsModel.count == 0 && !internal.loadData && internal.finishSearching
                text: qsTr("No airports found")
                hintText: qsTr("Enter airport/city name")
            }
            BusyIndicator {
                running: internal.loadData
                size: BusyIndicatorSize.Large
                anchors.centerIn: parent
            }
        }
    }
}
