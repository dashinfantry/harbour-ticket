import QtQuick 2.2
import Sailfish.Silica 1.0

import "../utils/Utils.js" as Utils

import "../utils"
import "../delegates"

Page {
    id: searchPage
    orientation: Orientation.Portrait

    property bool showDialog: false

    property variant airportsInfo: ({})

    property string origin
    property string originText
    property string destination
    property string destinationText
    property string originAirport
    property string destinationAirport
    property string currency: "eur"
    property string language: "en"
    property string seat: "Y"
    property string currentIp
    property string uuid

    property int passengers: 2
    property bool direct: false
    property string departureDateValue: qsTr("Select")
    property date departureSelectedDate: new Date()
    property bool departureDateValueIsSet: false
    property string returnDateValue: qsTr("Select")
    property date returnSelectedDate: new Date()
    property bool returnDateValueIsSet: false


    property bool loadData: false
    property bool finishSearching: false
    property bool showMainView: false
    property variant currentSearch: ({})

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
        app.newSearch.connect(startNewSearch)

        getFavorites()

        currency = database.currency
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
                var tmp = {"fav_origin": t.segments[0].origin, "fav_destination": t.segments[0].destination, "fav_departureDate": t.departureDate}
                favoritesModel.append(tmp)
            }
        }
    }

    function startNewSearch() {
        pageStack.push(firstWizardPage)
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
            app.newSearchAllowed = true
//            var ipAddr = JSON.parse(data)
//            var url = "http://www.travelpayouts.com/whereami?locale=ru&ip=" + ipAddr.ip

//            var parsed = JSON.parse(data)
//            if (parsed.status == "success") {
//                currentIp = parsed.query //ipAddr.ip
//            }
            currentIp = data

            console.log("My IP", currentIp)

            var url = "http://nano.aviasales.ru/places/top_" + language + ".json"
            Utils.performRequest("GET", url, getAirportsInfo)

            classSeatsModel.append({"name": qsTr("Econom class"), "seat": "Y"})
            classSeatsModel.append({"name": qsTr("Busines class"), "seat": "C"})
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

            busyIndicator.running = false
        }
    }

    function getCityInfo(data) {
        if (data !== "error") {
            var parsed = JSON.parse(data)
            if (Object.keys(parsed).length > 0) {
                airportsModel.append(parsed)
            }
        }
        loadData = false
        finishSearching = true
    }

    function getName(iata) {
        return airportsInfo[iata].name
    }

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
        id: classSeatsModel
    }

    ListModel {
        id: airportsModel
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
            MenuItem {
                text: qsTr("Search")
                onClicked: {
                    app.newSearchAllowed = false
                    pageStack.push(firstWizardPage)
                }
            }
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
                    pageStack.push(Qt.resolvedUrl("SearchPage.qml"), {searchType: type})
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
                    searchPage.origin = fav_origin
                    searchPage.originText = app.airportsInfo[fav_origin].name + " (" + fav_origin + ")"
                    searchPage.destination = fav_destination
                    searchPage.destinationText = app.airportsInfo[fav_destination].name + " (" + fav_destination + ")"
                    var currDate = new Date()
                    departureSelectedDate = new Date(fav_departureDate)
                    if (currDate > departureSelectedDate) {
                        departureSelectedDate = currDate
                    }
                    departureDateValue = Utils.getFullDate(departureSelectedDate)
                    departureDateValueIsSet = true
                    app.newSearchAllowed = false

                    pageStack.push(firstWizardPage)
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

        Component {
            id: searchAirport

            Dialog {
                id: d
                property string airportName
                property string airportIATA
                property string cityIata

                onBackNavigationChanged: {
                    airportsModel.clear()
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
                                var url = "http://nano.aviasales.ru/places_" + language + "?term=" + searchText
                                Utils.performRequest("GET", url, getCityInfo)
                                loadData = true
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
//                                visible: model.airport_name?true:false
                                text: (model.airport_name?model.airport_name:model.name) + " (" + model.iata + ")"
                            }
                            onClicked: {
                                d.airportName = model.airport_name?model.airport_name:model.name
                                d.airportIATA = model.iata
                                d.cityIata = model.city_iata?model.city_iata:model.iata
                                airportsModel.clear()
                                d.accept()
                            }
                        }
                        ViewPlaceholder {
                            enabled: airportsModel.count == 0&&!loadData&&finishSearching
                            text: showDialog?"No airports found":""
                            hintText: "Enter airport/city name"
                        }
                        BusyIndicator {
                            running: loadData
                            size: BusyIndicatorSize.Large
                            anchors.centerIn: parent
                        }
                    }
                }
            }
        }

        Component {
            id: firstWizardPage

            Dialog {
                canAccept: origin.length >= 2&&destination.length >= 2&&departureDateValueIsSet
                acceptDestination: searchPage
                acceptDestinationAction: PageStackAction.Pop

                Flickable {
                    // ComboBox requires a flickable ancestor
                    width: parent.width
                    height: parent.height
                    interactive: false

                    Column {
                        width: parent.width
                        DialogHeader {
                            acceptText: qsTr("Search")
                            cancelText: qsTr("Cancel")
                        }

                        ListItem {
                            id: originSelector
                            height: Theme.itemSizeMedium
                            width: parent.width
                            Label {
                                id: label
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.horizontalPageMargin
                                anchors.verticalCenter: parent.verticalCenter
                                text: !origin?qsTr('Origin:'):originText
                            }

                            function openSearchDialog() {
                                var dialog = pageStack.push(searchAirport)

                                dialog.accepted.connect(function() {
                                    originText = dialog.airportName + " (" + dialog.airportIATA + ")"
                                    origin = dialog.cityIata
                                    originAirport = dialog.airportName
                                })
                            }
                            onClicked: {
                                originSelector.openSearchDialog()
                            }
                        }
                        IconButton {
                            enabled: true // origin&&destination
                            icon.source: "image://theme/icon-m-shuffle"
                            onClicked: {
                                var tmp = label.text
                                label.text = labelDest.text
                                labelDest.text = tmp
                                var iata = origin
                                origin = destination
                                destination = iata
                            }
                        }

                        ListItem {
                            id: destinationSelector
                            height: Theme.itemSizeMedium
                            width: parent.width
                            Label {
                                id: labelDest
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.horizontalPageMargin
                                anchors.verticalCenter: parent.verticalCenter
                                text: !destination?qsTr('Destination:'):destinationText
                            }

                            function openSearchDialog() {
                                var dialog = pageStack.push(searchAirport)

                                dialog.accepted.connect(function() {
                                    destinationText = dialog.airportName + "(" + dialog.airportIATA + ")"
                                    destination = dialog.cityIata
                                    destinationAirport = dialog.airportName
                                })
                            }
                            onClicked: {
                                openSearchDialog()
                            }
                        }

                        ValueButton {
                            id: departureDate

                            function openDateDialog() {
                                var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", {
                                                date: departureSelectedDate
                                             })

                                dialog.accepted.connect(function() {
                                    var currDate = new Date()
                                    if (currDate <= dialog.date) {
                                        departureDateValue = dialog.dateText
                                        departureSelectedDate = dialog.date
                                        departureDateValueIsSet = true
                                    }

                                    //Depart date can not be from past
                                })
                            }

                            label: qsTr("Departure date:")
                            value: departureDateValue
                            width: parent.width
                            onClicked: openDateDialog()
                        }
                        TextSwitch {
                            id: comboBoxOneWayTicket
                            checked: true
                            text: qsTr("One way ticket")
                        }
                        ValueButton {
                            id: returnDateDate
                            enabled: !comboBoxOneWayTicket.checked

                            function openDateDialog() {
                                var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", {
                                                date: returnSelectedDate
                                             })

                                dialog.accepted.connect(function() {
                                    var currDate = new Date()
                                    if (currDate <= dialog.date) {
                                        returnDateValue = dialog.dateText
                                        returnSelectedDate = dialog.date
                                        returnDateValueIsSet = true
                                    }
                                    //Depart date can not be from past
                                })
                            }

                            label: qsTr("Return date:")
                            value: returnDateValue
                            width: parent.width
                            onClicked: openDateDialog()
                        }
                        SectionHeader {
                            text: qsTr("Adults count")
                        }
                        Row {
                            id: numberOfPassangers

                            anchors.horizontalCenter: parent.horizontalCenter
                            IconButton {
                                icon.source: "image://theme/icon-m-remove"
                                onClicked: {
                                    passengers = parseInt(adultsCount.text)
                                    if (passengers > 1) {
                                        passengers = passengers - 1
                                    }
                                    adultsCount.text = passengers
                                    console.log(passengers)
                                }
                            }
                            Label {
                                id: adultsCount

                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width * 0.25
                                horizontalAlignment: Text.AlignHCenter
                                text: "2"
                            }
                            IconButton {
                                icon.source: "image://theme/icon-m-add"
                                onClicked: {
                                    passengers = parseInt(adultsCount.text)
                                    if (passengers < 10) {
                                        passengers = passengers + 1
                                    }
                                    adultsCount.text = passengers
                                    console.log(passengers)
                                }
                            }
                        }
//                        Slider {
//                            id: numberOfPassangers
//                            width: parent.width
//                            label: qsTr("Number of passangers")
//                            minimumValue: 1
//                            maximumValue: 10
//                            value: passengers
//                            stepSize: 1
//                            valueText: qsTr("Adults: ") + value
//                            onValueChanged: {
//                                passengers = value
//                            }
//                        }
//                        SectionHeader { text: qsTr("Options") }
                        TextSwitch {
                            id: directTicketsOnly
                            checked: direct
                            text: qsTr("Without transfer")
                            onCheckedChanged: {
                                direct = checked
                            }
                        }
                        ComboBox {
                            id: classSelector

                            width: parent.width
                            label: qsTr('Seat class:')
                            currentIndex: 0

                            menu: ContextMenu {
                                Repeater {
                                    model: classSeatsModel

                                    MenuItem {
                                        text: model.name
                                        onClicked: {
                                            seat = model.seat
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                onCanceled: {
                    app.newSearchAllowed = true
                    showDialog = false
                }

                onAccepted: {
                    var url = "http://api.travelpayouts.com/v1/flight_search"

                    var postParms = {}
                    postParms.marker = Utils.marker
                    postParms.host = Utils.host
                    postParms.user_ip = currentIp
                    postParms.locale = language
                    postParms.trip_class = seat
                    postParms.passengers = {"adults": passengers, "children": 0, "infants": 0}
                    postParms.segments = [{"origin": origin, "destination": destination, "date": Utils.getFullDate(departureSelectedDate)}]

                    if (returnDateValueIsSet) {
                        postParms.segments.push({"origin": destination, "destination": origin, "date": Utils.getFullDate(returnSelectedDate)})
                    }

                    var s = Utils.createMD5(postParms)
                    postParms.signature = s

                    currentSearch["segments"] = [{"origin": origin, "destination": destination}]
                    currentSearch["departureDate"] = departureSelectedDate
                    currentSearch["passengers"] = {"adults": passengers, "children": 0, "infants": 0}
                    currentSearch["oneWay"] = direct
                    currentSearch["tripClass"] = seat
                    if (returnDateValueIsSet) {
                        currentSearch["returnDateDate"] = returnSelectedDate
                        currentSearch["segments"].push({"origin": destination, "destination": origin})
                    }
                    var key = origin+"-"+destination
                    app.currentSearch = key
                    database.storeFavorite(key, JSON.stringify(currentSearch))

                    showDialog = true
                    loadData = true
                    finishSearching = false

                    app.newSearchAllowed = false

                    pageStack.push(Qt.resolvedUrl("SearchResultsPage.qml"), {searchUrl: url, searchParams: postParms, directFlight: direct})
                }
            }
        }
    }

}
