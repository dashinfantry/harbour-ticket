import QtQuick 2.2
import Sailfish.Silica 1.0

import "../utils/Utils.js" as Utils

import "../utils"
import "../delegates"

Page {
    property bool showMainView: false

    property string searchUrl
    property variant searchParams
    property bool directFlight: false

    property string uuid

    property variant currencyRates: ({})

    property variant _searchResults: []

    property string timeIsExpired: "Please, refresh search results"

    property bool _convertPrice: false
    property string _selectedCurrency

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
        id: requestTickets
        property int count: 0
        interval: 5000
        repeat: true
        onTriggered: {
            if (count < 5) {
                var url = "http://api.travelpayouts.com/v1/flight_search_results?uuid=" + uuid
                Utils.performRequest("GET", url, getResults)
            } else {
                stop()
                count = 0
                busyIndicator.running = false
            }
            count += 1
        }
    }

    Timer {
        id: searchTimeout
        interval: 900000000 // 15 min
        onTriggered: {
            console.log(timeIsExpired)
        }
    }

    ListModel {
        id: resultsModel
    }

    function showResults(data) {
        if (data !== "error") {
            var parsed = JSON.parse(data)
            if (parsed.meta.uuid) {
//                console.log(JSON.stringify(parsed))
                currencyRates = parsed.currency_rates
//                console.log(JSON.stringify(currencyRates))
                uuid = parsed.meta.uuid
                requestTickets.start()
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

    function getResults(data) {
        if (data !== "error") {
            var parsed = JSON.parse(data)

            for (var a in parsed) {
                var part = parsed[a]
//                console.log("\n\n\n\n",JSON.stringify(part), "\n\n\n\n")
                var _search_id = part.search_id
                var airportsInfo = part.airports
                var airlinesInfo = part.airlines

                var airports = []
                for (var id in part.segments) {
                    var t = part.segments[id].origin + " - " + part.segments[id].destination
                    airports.push(t)
                }
                for (var i in part.proposals) {
//                    console.log(JSON.stringify(part.proposals[i]))
                    var proposal = part.proposals[i]

                    var total_duration = proposal.total_duration
                    var transfers_count = proposal.max_stops
                    var validating_carrier = proposal.validating_carrier

                    var departure_date = proposal.segments_time[0][0]
                    var arrival_date = proposal.segments_time[0][1]

                    var terms = Object.keys(proposal.terms)
//                    console.log("\n\nterms",JSON.stringify(terms))
                    for (var j in terms) {
                        var term = proposal.terms[terms[j]]
//                        console.log("\n\nterm",JSON.stringify(term))
                        if (term.unified_price > 0) {
                            var points = airports.filter(Utils.onlyUnique).join(" | ")
                            if (!directFlight) {
                                if (!_convertPrice) {
                                    _selectedCurrency = term.currency
                                }
                                var converted_price = (term.unified_price/currencyRates[_selectedCurrency.toLowerCase()]).toFixed(0)
                                var tmp_item = {
                                    "route": points,
                                    "depart_date": departure_date,
                                    "arrival_date": arrival_date,
                                    "carrier": validating_carrier,
                                    "duration": total_duration,
                                    "_currency": _selectedCurrency,
                                    "_value": converted_price,
                                    "transfers": transfers_count,
                                    "fullInfo": proposal,
                                    "_search_id": _search_id,
                                    "_currencyRates": currencyRates,
                                    "airportsInfo": airportsInfo,
                                    "airlinesInfo": airlinesInfo
                                }
                                resultsModel.append(tmp_item)
                                _searchResults.push(tmp_item)
                            } else {
                                if (proposal.is_direct) {
                                    if (!_convertPrice) {
                                        _selectedCurrency = term.currency
                                    }
                                    var converted_price = (term.unified_price/currencyRates[_selectedCurrency.toLowerCase()]).toFixed(0)
                                    var tmp_item = {
                                        "route": points,
                                        "depart_date": departure_date,
                                        "arrival_date": arrival_date,
                                        "carrier": validating_carrier,
                                        "duration": total_duration,
                                        "_currency": _selectedCurrency,
                                        "_value": converted_price,
                                        "transfers": transfers_count,
                                        "fullInfo": proposal,
                                        "_search_id": _search_id,
                                        "_currencyRates": currencyRates,
                                        "airportsInfo": airportsInfo,
                                        "airlinesInfo": airlinesInfo
                                    }
                                    resultsModel.append(tmp_item)
                                    _searchResults.push(tmp_item)
                                }
                            }
                        }
                    }
                }
            }
            if (resultsModel.count > 0) {
                busyIndicator.running = false
                showMainView = true
            }
        }

    }

    Component.onCompleted: {
        searchTimeout.start()
        resultsModel.clear()
        app.newSearchAllowed = false
//        console.log(searchUrl, searchParams)
        if (searchUrl && searchParams) {
            Utils.performRequest("POST", searchUrl, showResults, searchParams)
        }

        _convertPrice = database.convertCurrency
        _selectedCurrency = database.currency
    }

    Component.onDestruction: {
        searchTimeout.stop()
    }

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Sort by price: ") + qsTr("low to high")
                enabled: !requestTickets.running
                onClicked: {
                    showMainView = false
                    busyIndicator.running = true
                    resultsModel.clear()
                    _searchResults.sort(sortBy('_value', false, parseInt))
                    for (var i in _searchResults) {
                        resultsModel.append(_searchResults[i])
                    }
                    busyIndicator.running = false
                    showMainView = true
                }
            }
            MenuItem {
                text: qsTr("Sort by airline")
                enabled: !requestTickets.running
                onClicked: {
                    showMainView = false
                    busyIndicator.running = true
                    resultsModel.clear()
                    _searchResults.sort(sortBy('carrier', false, String))
                    for (var i in _searchResults) {
                        resultsModel.append(_searchResults[i])
                    }
                    busyIndicator.running = false
                    showMainView = true
                }
            }
        }

        SilicaListView {
            id: mainListView
            anchors.fill: parent
            spacing: Theme.paddingSmall
            clip: true
            visible: !busyIndicator.running
            model: resultsModel
            delegate: TicketInfoDelegate {
                ticket_price: _value + "\n" + _currency.toUpperCase()
                orig: route
                date_from: depart_date
                date_to: arrival_date
                airlineIata: carrier
                fly_duration: duration
                transfers_count: transfers
                search_id: _search_id
                currencyRatesInfo: _currencyRates
                proposal: fullInfo
                airports: airportsInfo
                airlines: airlinesInfo
            }
            header: PageHeader {
                title: qsTr("Results")

                BusyIndicator {
                    id: indicator
                    running: requestTickets.running
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
                    text: qsTr("Found: ") + resultsModel.count
                    color: Theme.secondaryColor
                }
            }

            VerticalScrollDecorator {flickable: mainListView}
            ViewPlaceholder {
                enabled: resultsModel.count == 0&&!busyIndicator.running
                text: resultsModel.count == 0?"No tickets found":""
                hintText: "Pull down to search tickets"
            }
        }
    }
}
