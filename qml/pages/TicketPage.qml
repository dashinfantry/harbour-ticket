import QtQuick 2.2
import Sailfish.Silica 1.0

import "Utils.js" as Utils

Page {
    id: ticketPage
    property variant ticket: ({})


    property variant currencyRates: ({})

    property string _currency

    property string _url
    property string _search_id
    property string _price
//    property variant airportsInfo: ({})
    property string language: "en"

    function buyTicket(data) {
        if (data !== "error") {
            console.log(data)
            var parsed = JSON.parse(data)
            if (parsed.method == "GET") {
                console.log(parsed.url)
//                Qt.openUrlExternally(parsed.url)
                pageStack.push(Qt.resolvedUrl("WebPage.qml"), {pageUrl: parsed.url})
            }
        }
    }

    function fromMinToHours(value) {
        var hours = Math.floor( value / 60);
        var minutes = value % 60;

        return hours + qsTr("h ") + minutes + qsTr("m")
    }

    function getAirportsInfo(data) {
        if (data !== "error") {
            var parsed = JSON.parse(data)
            var _airportsInfo = {}
            for(var i in parsed) {
                if(parsed[i].airport_name != "") {
                    _airportsInfo[parsed[i].iata] = {"iata": parsed[i].iata, "name": parsed[i].name, "coordinates": parsed[i].coordinates}
                }
            }
            airportsInfo = _airportsInfo
            var terms = Object.keys(ticket.terms)
            for (var a in terms) {
                var term = ticket.terms[terms[a]]
                var convertedPrice = (term.unified_price/currencyRates[_currency.toLowerCase()]).toFixed(0)
                _price = convertedPrice + " " + _currency.toUpperCase()
                _url = term.url
            }
            for (var id in ticket.segment) {
                var _flights = ticket.segment[id].flight
                for (var j in _flights) {
                    var flight = _flights[j]
    //                console.log(JSON.stringify(flight))
                    flights.append({
                                        "departure": airportsInfo[flight.departure].name,
                                        "arrival": airportsInfo[flight.arrival].name,
                                        "departure_time": flight.local_departure_timestamp,
                                        "arrival_time": flight.local_arrival_timestamp,
                                        "flight_number": flight.number,
                                       "carrier": flight.operating_carrier,
                                       "duration": flight.duration
                                   })
                }
            }
        }
        busyIndicator.running = false
        content.visible = true

    }

    function getLink(data) {

    }

    DataBase {
        id: database
    }

    ListModel {
        id: flights
    }

    BusyIndicator {
        id: busyIndicator
        running: true
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
    }

    Component.onCompleted: {
//        database.initDatabase()
//        var languageIndex = database.getName("language")
//        if (languageIndex) {
//            language = languageIndex.toLowerCase()
//        } else {
//            database.storeData("language", 0, "EN")
//        }
//        var url = "http://nano.aviasales.ru/places/top_" + language + ".json"
//        Utils.performRequest("GET", url, getAirportsInfo)
        var terms = Object.keys(ticket.terms)
        for (var a in terms) {
            var term = ticket.terms[terms[a]]
            var convertedPrice = (term.unified_price/currencyRates[term.currency]).toFixed(0)
            _price = convertedPrice + " " + term.currency.toUpperCase()
            _url = term.url
        }
        for (var id in ticket.segment) {
            var _flights = ticket.segment[id].flight
            for (var j in _flights) {
                var flight = _flights[j]
//                console.log(JSON.stringify(flight))
                var depart = app.airportsInfo[flight.departure]?app.airportsInfo[flight.departure].name:"" + " (" + flight.departure + ")"
                var arriv = app.airportsInfo[flight.arrival]?app.airportsInfo[flight.arrival].name:"" + " (" + flight.arrival + ")"
                flights.append({
                                   "departure": depart,
                                   "arrival": arriv,
                                   "departure_time": flight.local_departure_timestamp,
                                   "arrival_time": flight.local_arrival_timestamp,
                                   "flight_number": flight.number,
                                   "carrier": flight.operating_carrier,
                                   "duration": flight.duration
                               })
            }
        }
        busyIndicator.running = false
        content.visible = true
    }

    SilicaFlickable {
        id: content
        anchors.fill: parent
        visible: false
        PageHeader {
            id: pageHeader
            title: _price
        }
        ListView {
            id: listView
            anchors.top: pageHeader.bottom
            anchors.margins: Theme.paddingMedium
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: buyButton.top
            width: parent.width
            clip: true
            spacing: Theme.paddingSmall
            model: flights
            delegate: ListItem {
                height: Theme.itemSizeSmall + logo.height + flightNumber.height + origin.height + destination.height + tripDuration.height
                contentHeight:  Theme.itemSizeSmall + logo.height + flightNumber.height + origin.height + destination.height + tripDuration.height
                width: parent.width

                Image {
                    id: logo
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.top: parent.top
//                    width: Theme.iconSizeExtraLarge
                    source: carrier?"http://pics.avs.io/264/87/"+ carrier +".png":""
                    //source: iata?"http://ios.aviasales.ru/logos/xxhdpi/"+ iata +".png":""
                    fillMode: Image.PreserveAspectFit
                }
                Label {
                    id: flightNumber
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.top: logo.bottom
                    text: qsTr("Flight number: ") + flight_number
                }
                Label {
                    id: origin
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.top: flightNumber.bottom
                    text: qsTr("Origin: ") + departure
                }
                Text {
                    id: departureDate
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.top: origin.bottom
                    text: qsTr("Depature: ") + Utils.fromUnixToLocalDateTime(departure_time)
                    color: Theme.secondaryColor
                }
                Label {
                    id: destination
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.top: departureDate.bottom
                    text: qsTr("Destination: ") + arrival
                }
                Text {
                    id: arrivalDate
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.top: destination.bottom
                    text: qsTr("Arrival: ") + Utils.fromUnixToLocalDateTime(arrival_time)
                    color: Theme.secondaryColor
                }
                Label {
                    id: tripDuration
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.top: arrivalDate.bottom
                    text: qsTr("Trip duration: ") + fromMinToHours(duration)
                }
            }
        }

        Button {
            id: buyButton
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Buy")

            onClicked: {
                var url = "http://api.travelpayouts.com/v1/flight_searches/" + _search_id + "/clicks/" + _url + ".json"
                Utils.performRequest("GET", url, buyTicket)
            }
        }
    }
}
