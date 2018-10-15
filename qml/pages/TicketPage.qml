import QtQuick 2.2
import Sailfish.Silica 1.0

import "../utils/Utils.js" as Utils
import "../utils"

Page {
    id: ticketPage
    property variant ticket: ({})


    property variant currencyRates: ({})

    property string _currency

    property string _search_id
    property variant airports: ({})
    property variant airlines: ({})

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

    QtObject {
        id: internal

        property string price
        property string language: "en"
        property string url
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
        var terms = Object.keys(ticket.terms)
        for (var a in terms) {
            var term = ticket.terms[terms[a]]
            if (database.convertCurrency) {
                internal.price = (term.unified_price/currencyRates[database.currency]).toFixed(0) + " " + database.currency.toUpperCase()
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
                                   "aircraft": flight.aircraft?flight.aircraft:flight.equipment
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
                Text {
                    anchors.left: logo.right
                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.verticalCenter: logo.verticalCenter
                    color: Theme.secondaryColor
                    font.bold: true

                    text: airlines[carrier].name

                }
                Text {
                    id: flightNumber
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.top: logo.bottom
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                    text: qsTr("<b>Flight number:</b> ") + carrier + flight_number + qsTr("<br><b>Aircraft:</b> ") + aircraft
                }
                Text {
                    id: origin
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.right: parent.left
                    anchors.rightMargin: Theme.paddingMedium
                    anchors.top: flightNumber.bottom
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.secondaryColor
                    text: qsTr("<b>Origin:</b> ") + departure
                    wrapMode: Text.WordWrap
                }
                Text {
                    id: departureDate
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.right: parent.left
                    anchors.rightMargin: Theme.paddingMedium
                    anchors.top: origin.bottom
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                    text: qsTr("<b>Depature:</b> ") + Utils.fromUnixToShortFormat(departure_time)
                    wrapMode: "WordWrap"
                }
                Text {
                    id: destination
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.right: parent.left
                    anchors.rightMargin: Theme.paddingMedium
                    anchors.top: departureDate.bottom
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.secondaryColor
                    text: qsTr("<b>Destination:</b> ") + arrival
                    wrapMode: Text.WordWrap
                }
                Text {
                    id: arrivalDate
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.right: parent.left
                    anchors.rightMargin: Theme.paddingMedium
                    anchors.top: destination.bottom
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                    text: qsTr("<b>Arrival:</b> ") + Utils.fromUnixToShortFormat(arrival_time)
                }
                Text {
                    id: tripDuration
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.right: parent.left
                    anchors.rightMargin: Theme.paddingMedium
                    anchors.top: arrivalDate.bottom
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                    text: qsTr("Trip duration: ") + Utils.fromMinToHours(duration)
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
                var url = "http://api.travelpayouts.com/v1/flight_searches/" + _search_id + "/clicks/" + internal.url + ".json"
                Utils.performRequest("GET", url, buyTicket)
            }
        }
    }
}
