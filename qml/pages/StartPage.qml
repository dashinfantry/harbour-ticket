import QtQuick 2.2
import Sailfish.Silica 1.0

import "../utils/Utils.js" as Utils

import "../utils"
import "../delegates"

Page {
    id: root
    orientation: Orientation.Portrait

    property variant airportsInfo: ({})
    property string language: "en"
    property string currentIp
    property date departureSelectedDate: new Date()

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
            }
            count += 1
        }
    }

    Component.onCompleted: {
        language = database.language

        hint.visible = database.showHints
        hint.running = database.showHints

        Utils.performRequest("GET", Utils.getMyIpUrl, getCurrentIp)
    }

    ListModel {
        id: searchTypesList

        ListElement {
            type: "simple"
            name: qsTr("One way search")
            descr: qsTr("One way ticket")
            image: "image://theme/icon-m-home"
        }
        ListElement {
            type: "return"
            name: qsTr("Round trip search")
            descr: qsTr("Round trip")
            image: "image://theme/icon-m-location"
        }
        ListElement {
            type: "complex"
            name: qsTr("Complex search")
            descr: qsTr("Fly with more than two stops")
            image: "image://theme/icon-m-gps"
        }
    }


    function getFavorites() {
        var favorites = database.getFavorites()
        if (favorites) {
            favoritesModel.clear()
            for (var id in favorites) {
//                console.log(favorites[id])
                var t = JSON.parse(favorites[id])
//                console.log("origin", t.segments[0].origin)
                var tmp = {"fav_origin": t.segments[0].origin, "fav_destination": t.segments[0].destination, "fav_departureDate": t.departureDate,
                            "oneWay": t.oneWay, "adults": t.passengers.adults, "children": t.passengers.children, "tripClass": t.tripClass, "directFlight": t.oneWay}
                favoritesModel.append(tmp)
            }
        }
    }

    function saveFavorites(data) {
        for (var i in data) {
            //
            database.storeFavorite(data[i].key, data[i].value)
        }
        getFavorites()
    }

    function getCurrentIp(data) {
        if(data !== "error") {
            app.newSearchAllowed = false
            currentIp = data

            console.log("My IP", currentIp)

//            var url = "http://nano.aviasales.ru/places/top_" + language + ".json"
//            Utils.performRequest("GET", url, getAirportsInfo)
        }
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
            app.airportsInfo = _airportsInfo
            getFavorites()

            busyIndicator.running = false
        }
    }

//    function getCityInfo(data) {
//        if (data !== "error") {
//            var parsed = JSON.parse(data)
//            if (Object.keys(parsed).length > 0) {
//                airportsModel.append(parsed)
//            }
//        }
//        loadData = false
//        finishSearching = true
//    }

//    function getName(iata) {
//        return airportsInfo[iata].name
//    }

    function showResults(data) {
        if (data !== "error") {
            var parsed = JSON.parse(data)
            if (parsed.meta.uuid) {
//                console.log(JSON.stringify(parsed))
                uuid = parsed.meta.uuid
                requestTickets.start()
                var url = "http://api.travelpayouts.com/v1/flight_search_results?uuid=" + uuid
                Utils.performRequest("GET", url, getResults)
            }
        }
    }

    ListModel {
        id: favoritesModel
    }

    SilicaFlickable {
        anchors.fill: parent

        //            pullDownMenu:
        PageHeader {
            id: head
            title: qsTr("Avia tickets")

            BusyIndicator {
                id: indicator
                running: requestTickets.running
                size: BusyIndicatorSize.Small
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: Theme.paddingMedium
            }
        }
        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
                }
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
                }
            }
//            MenuItem {
//                text: qsTr("Search")
//                onClicked: {
//                    app.newSearchAllowed = false
//                    pageStack.push(Qt.resolvedUrl("../delegates/SearchDialog.qml"), {currentIp: root.currentIp})
//                }
//            }
        }

        ListView {
            id: searchTypes

            anchors.top: head.bottom
            height: (Theme.itemSizeMedium + Theme.paddingMedium) * searchTypesList.count
            width: parent.width
            spacing: Theme.paddingMedium
            interactive: false
            model: searchTypesList
            delegate: IconTextSwitch {
                automaticCheck: false
                text: name
                icon.source: image
                description: descr
                onClicked: {
                    if (type === "complex") {
                        pageStack.push(Qt.resolvedUrl("../delegates/ComplexSearchDialog.qml"), {currentIp: root.currentIp})
                    } else {
                        var oneway = type === "simple"
                        pageStack.push(Qt.resolvedUrl("../delegates/SearchDialog.qml"), {currentIp: root.currentIp, oneWay: oneway})
                    }
                }
            }

        }

        //*** FAVORITES ***
        SilicaListView {
            id: favoritesListView

            anchors { top: searchTypes.bottom; left: parent.left; right: parent.right; bottom: offers.top }
            spacing: Theme.paddingSmall
            clip: true
            visible: !busyIndicator.running
            header: SectionHeader {
                text: qsTr("Search history")
            }

            model: favoritesModel
            delegate:  FavoritesDelegate {
                id: favoritesDelegate

                origin: fav_origin
                destination: fav_destination
                airportOriginFullNameText: app.airportsInfo[fav_origin].name
                airportDestinationFullNameText: app.airportsInfo[fav_destination].name
                departureDate: fav_departureDate

                onClicked: {
//                    root.origin = fav_origin
//                    root.originText = app.airportsInfo[fav_origin].name + " (" + fav_origin + ")"
//                    root.destination = fav_destination
//                    root.destinationText = app.airportsInfo[fav_destination].name + " (" + fav_destination + ")"
                    var currDate = new Date()
                    departureSelectedDate = new Date(fav_departureDate)
                    if (currDate > departureSelectedDate) {
                        departureSelectedDate = currDate
                    }
                    app.newSearchAllowed = false

//                    var oneway = typeof oneWay === "undefined" ? oneWay:true
                    pageStack.push(Qt.resolvedUrl("../delegates/SearchDialog.qml"), {currentIp: root.currentIp, oneWay: true, direct: directFlight,
                                       origin: fav_origin, destination: fav_destination,
                                       originText: app.airportsInfo[fav_origin].name + " (" + fav_origin + ")",
                                       destinationText: app.airportsInfo[fav_destination].name + " (" + fav_destination + ")",
                                       passengers: adults, childrens: children,
                                       departureSelectedDate: departureSelectedDate, seat: tripClass,
                                       departureDateValue: Utils.getFullDate(departureSelectedDate), departureDateValueIsSet: true})
                }
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Delete")
                        onClicked: {
                            showRemorseItem()
                        }
                    }
                }

                RemorseItem { id: remorse }

                 function showRemorseItem() {
                     var idx = index
                     remorse.execute(favoritesDelegate, "Deleting", function() {
                         var obj = favoritesModel.get(idx)
                         var key = obj.fav_origin+"-"+obj.fav_destination
                         database.deleteFavorite(key)
                         favoritesModel.remove(idx)
                     } )
                 }
            }

        }

//        ListItem {
//            id: offers

//            anchors.bottom: parent.bottom
//            anchors.bottomMargin: Theme.horizontalPageMargin
//            anchors.horizontalCenter: parent.horizontalCenter
////            text: qsTr("Special offers")

//            onClicked: {
//                var url = "http://api.travelpayouts.com/v2/prices/special-offers?token=" + Utils.token
//                pageStack.push(Qt.resolvedUrl("AirlinesOffers.qml"), {xmlSource: url})
//            }
//        }

        StartScreenItem {
            id: offers

            anchors.bottom: offers1.top
            anchors.bottomMargin: Theme.horizontalPageMargin
            width: parent.width
            title: "Special offers"
            iconSource: "image://theme/icon-m-gps"

            onClicked: {
                var url = "http://www.jetradar.com/deals.atom/"
                pageStack.push(Qt.resolvedUrl("AirlinesOffers.qml"), {xmlSource: url})
            }
        }

        StartScreenItem {
            id: offers1

            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.horizontalPageMargin
            width: parent.width
            title: "Special offers1"
            iconSource: "image://theme/icon-m-gps"

            onClicked: {
                var url = "http://api.travelpayouts.com/v2/prices/special-offers?token=" + Utils.token
                pageStack.push(Qt.resolvedUrl("AirlinesOffers.qml"), {xmlSource: url})
            }
        }

        TouchInteractionHint {
            id: hint
            Component.onCompleted: restart()
            interactionMode: TouchInteraction.Pull
            direction: TouchInteraction.Down
        }

        InteractionHintLabel {
            visible: hint.visible
            text: qsTr("Pull down and select Search")
            opacity: hint.running ? 1.0 : 0.0
            Behavior on opacity { FadeAnimation {} }
            width: parent.width
            invert: true
        }
    }
}
