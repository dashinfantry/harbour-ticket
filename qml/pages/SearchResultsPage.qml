import QtQuick 2.2
import Sailfish.Silica 1.0

import dataproxy.Data 1.0

import "../utils/Utils.js" as Utils

import "../utils"
import "../delegates"

Page {
    property bool showMainView: false

    property string searchUrl
    property variant searchParams
    property bool directFlight: false
    property string uuid

    property variant _searchResults: []

    property string timeIsExpired: "Please, refresh search results"


    QtObject {
        id: internal

        property bool searchInProgress: false
        property int numberOfTickets: 0
        property variant currencyRates: ({})
        property bool convertPrice: false
        property string selectedCurrency

        function getPrice(value, unifiedValue, currencyName) {
            if (internal.convertPrice) {
                return (unifiedValue/internal.currencyRates[internal.selectedCurrency]).toFixed(0) + " " + internal.selectedCurrency.toUpperCase()
            } else {
                return value + " " + currencyName.toUpperCase()
            }
        }
    }

    DataBase {
        id: database
    }

    BusyIndicator {
        id: busyIndicator
        running: true
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
    }

    Timer {
        id: searchTimeout
        interval: 900000000 // 15 min
        onTriggered: {
            console.log(timeIsExpired)
        }
    }

    Data {
        id: searchTickets

        onTicketsModelChanged: {
//            console.log("tickets model changed")
            busyIndicator.running = false
            internal.numberOfTickets = searchTickets.getTicketsCount()
        }

        onSearchFinished: {
            internal.searchInProgress = false
        }

        onCurrencyRatesChanged: {
            internal.currencyRates = searchTickets.currencyRates[0].data
//            console.log("currencyRates", JSON.stringify(internal.currencyRates))
        }

        onTicketsModelSorted: {
            busyIndicator.running = false
            mainListView.model = searchTickets.ticketsModel
        }
    }

    function showResults(data) {
        if (data !== "error") {
            var parsed = JSON.parse(data)
            if (parsed.meta.uuid) {
//                console.log(JSON.stringify(parsed))
//                currencyRates = parsed.currency_rates
//                console.log(JSON.stringify(currencyRates))
                uuid = parsed.meta.uuid
                var url = "http://api.travelpayouts.com/v1/flight_search_results?uuid=" + uuid
                Utils.performRequest("GET", url, getResults)
            }
        }
    }

    function sortBy(field, reverse, primer){

       var key = primer ?
           function(x) {return primer(x[field])} :
           function(x) {return x[field]}

       reverse = !reverse ? 1 : -1

       return function (a, b) {
           a = key(a)
           b = key(b)
           return reverse * ((a > b) - (b > a))
         }
    }

    Component.onCompleted: {
        searchTimeout.start()
        app.newSearchAllowed = false
//        console.log(searchUrl, searchParams)
        if (searchUrl && searchParams) {

            var tmp = ({})
            tmp.url = searchUrl
            tmp.params = searchParams
            tmp.directFlight = directFlight
            searchTickets.clearTicketsList()
            searchTickets.getTicketsList(JSON.stringify(tmp))
            internal.searchInProgress = true
        }

        internal.convertPrice = database.convertCurrency
        internal.selectedCurrency = database.currency
    }

    Component.onDestruction: {
        searchTimeout.stop()
    }

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Sort by price: ") + qsTr("low to high")
                enabled: !internal.searchInProgress && !busyIndicator.running
                onClicked: {
                    busyIndicator.running = true
                    searchTickets.sortByPrice()
                }
            }
            MenuItem {
                text: qsTr("Sort by duration")
                enabled: !internal.searchInProgress && !busyIndicator.running
                onClicked: {
                    busyIndicator.running = true
                    searchTickets.sortByDuration()
                }
            }
        }

        SilicaListView {
            id: mainListView
            anchors.fill: parent
            spacing: Theme.paddingSmall
            clip: true
            visible: !busyIndicator.running
            model: searchTickets.ticketsModel
            delegate: TicketInfoDelegate {
                ticket_price: internal.getPrice(model.data.price, model.data._value, model.data._currency)//model.data.price + "\n" + model.data._currency.toUpperCase()
                _currency: model.data._currency
                orig: model.data.route
                date_from: model.data.depart_date
                date_to: model.data.arrival_date
                airlineIata: model.data.carrier
                fly_duration: model.data.duration
                transfers_count: model.data.transfers
                search_id: model.data._search_id
                currencyRatesInfo: internal.currencyRates
                proposal: model.data.fullInfo
                airports: model.data.airportsInfo
                airlines: model.data.airlinesInfo
                local_arrival: model.data.local_arrival_timestamp
                local_departure: model.data.local_departure_timestamp
                unified_price: model.data._value
            }
            header: PageHeader {
                title: qsTr("Results")

                BusyIndicator {
                    id: indicator
                    running: internal.searchInProgress
                    size: BusyIndicatorSize.Small
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: Theme.horizontalPageMargin
                }
                Text {
                    id: ticketsCount
                    anchors.left: indicator.right
                    anchors.leftMargin: Theme.paddingSmall
                    anchors.verticalCenter: indicator.verticalCenter
                    text: qsTr("Found: ") + internal.numberOfTickets
                    color: Theme.secondaryColor
                }
            }

            VerticalScrollDecorator {flickable: mainListView}
            ViewPlaceholder {
                enabled: internal.numberOfTickets == 0&&!busyIndicator.running
                text: internal.searchInProgress?qsTr("Search is in progress"):qsTr("No tickets found")
                hintText: internal.searchInProgress?qsTr("Please wait"):qsTr("Please, change the search request")
            }
        }
    }
}
