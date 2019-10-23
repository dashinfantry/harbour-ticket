import QtQuick 2.6
import Sailfish.Silica 1.0

import dataproxy.Data 1.0

import "../utils/Utils.js" as Utils
import "../utils"

Dialog {

    id: d
    property string airportName
    property string airportIATA
    property string cityIata

    onBackNavigationChanged: {
        serachAirports.clearAirportsList()
    }

    Component.onCompleted: {
        searchField.focus = true
    }


    Data {
        id: serachAirports

        onAirportModelChanged: {
            internal.loadData = false
        }
    }

    DataBase {
        id: database
    }

    QtObject {
        id: internal

        property bool loadData: false
        property bool finishSearching: false

        function searchAirport() {
            var searchText = searchField.text.replace(/ /g, '%20')
            var lang = database.language.toLowerCase()
            if (lang !== "en" || lang !== "ru") {
                lang = "en"
            }

            serachAirports.getAirportsList(searchText)
            internal.loadData = true
        }
    }

    Timer {
        id: startSearch
        interval: 3000
        repeat: false

        onTriggered: {
            internal.searchAirport()
        }
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
            focus: true

            onTextChanged: {
                if(searchField.text.length > 2) {
                    startSearch.restart()
                }
            }

            EnterKey.onClicked: {
                if(searchField.text.length > 2) {
                    startSearch.stop()
                    internal.searchAirport()
                }
            }
        }
        ListView {
            clip: true
            spacing: Theme.paddingSmall
            width: parent.width
            anchors.top: searchField.bottom
            anchors.bottom: parent.bottom

            model: serachAirports.airportModel

            delegate: ListItem {
                height: Theme.itemSizeSmall
                width: parent.width

                IconTextItem {
                    iconSource: model.data.airport_name ?
                                    "../images/airport_target.svg" :
                                    "../images/target.svg"
                    fontSize: Theme.fontSizeExtraSmall
                    title: (model.data.airport_name ?
                                model.data.airport_name + ": " + model.data.name :
                                qsTr("Location: ") + model.data.name) + " (" + model.data.iata + ")"
                    onClicked: {
                        d.airportName = model.data.airport_name?model.data.airport_name:model.data.name
                        d.airportIATA = model.data.iata
                        d.cityIata = model.data.city_iata ? model.data.city_iata : model.data.iata
                        serachAirports.clearAirportsList()
                        d.accept()
                    }
                }

                Separator {
                    anchors.bottom: parent.bottom
                    width: parent.width
                }
            }
            ViewPlaceholder {
                enabled: serachAirports.getAirportsCount() == 0 && !internal.loadData && internal.finishSearching
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

