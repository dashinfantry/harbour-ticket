import QtQuick 2.2
import Sailfish.Silica 1.0

import "../utils/Utils.js" as Utils
import "../utils"
import "../delegates"

Page {
    id: ticketPage
    property variant ticket: ({})
    property int unified_price: 0
    property variant currencyRates: ({})

    property string _currency

    property string _search_id
    property variant airports: ({})
    property variant airlines: ({})

    function buyTicket(data) {
        if (data !== "error") {
//            console.log(data)
            var parsed = JSON.parse(data)
            if (parsed.method == "GET") {
//                console.log(parsed.url)
                if (database.openInBrowser) {
                    Qt.openUrlExternally(parsed.url)
                } else {
                    pageStack.push(Qt.resolvedUrl("WebPage.qml"), {pageUrl: parsed.url})
                }
            } else {
                console.log("Unsupported link")
            }
        }
    }

    QtObject {
        id: internal

        property string price
        property string language: "en"
        property string url
        property variant flights_baggage: ([])
        property variant flights_handbags: ([])
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
//        console.log(JSON.stringify(ticket))
        var terms = Object.keys(ticket.terms)
        for (var a in terms) {
            var term = ticket.terms[terms[a]]
            internal.flights_baggage = term.flights_baggage[0]
            internal.flights_handbags = term.flights_handbags[0]
            if (database.convertCurrency) {
                internal.price = (term.unified_price/currencyRates[database.currency]).toFixed(0) + " " + database.currency.toUpperCase()
            } else {
                internal.price = term.price + " " + term.currency.toUpperCase()
            }

//            var convertedPrice = (term.unified_price/currencyRates[term.currency]).toFixed(0)
//            _price = convertedPrice + " " + term.currency.toUpperCase()
            internal.url = term.url
        }
        for (var id in ticket.segment) {
            var _flights = ticket.segment[id].flight
            for (var j in _flights) {
                var flight = _flights[j]
//                console.log(JSON.stringify(flight))
                var depart = airports[flight.departure].name + " (" + flight.departure + ")"
                var arriv = airports[flight.arrival].name + " (" + flight.arrival + ")"
                flights.append({
                                   "departure": depart,
                                   "arrival": arriv,
                                   "departure_time": flight.local_departure_timestamp,
                                   "arrival_time": flight.local_arrival_timestamp,
                                   "flight_number": flight.number,
                                   "carrier": flight.operating_carrier,
                                   "duration": flight.duration,
                                   "aircraft": flight.aircraft?flight.aircraft:flight.equipment,
                                   "delay": flight.delay,
                                   "flights_handbags": internal.flights_handbags[j],
                                   "flights_baggage": internal.flights_baggage[j]
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
            title: internal.price
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
            spacing: Theme.paddingMedium
            model: flights
            delegate: TicketDelegate{
            }
        }

        Button {
            id: buyButton
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Buy")

            onClicked: {
                var url = "http://api.travelpayouts.com/v1/flight_searches/" + _search_id + "/clicks/" + internal.url + ".json"
                Utils.performRequest("GET", url, buyTicket)
            }
        }
    }
}
