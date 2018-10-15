import QtQuick 2.6
import Sailfish.Silica 1.0

import "../utils/Utils.js" as Utils
import "../utils"

Dialog {

    property bool oneWay: false

    property string origin
    property string originText
    property string destination
    property string destinationText
    property string originAirport
    property string destinationAirport
    property string currency: "eur"
    property string seat: "Y"
    property string currentIp

    property int passengers: 2
    property int childrens: 0
    property bool direct: false
    property string departureDateValue: qsTr("Select")
    property date departureSelectedDate: new Date()
    property bool departureDateValueIsSet: false
    property string returnDateValue: qsTr("Select")
    property date returnSelectedDate: new Date()
    property bool returnDateValueIsSet: false
    property variant currentSearch: ({})

    canAccept: origin.length >= 2&&destination.length >= 2&&departureDateValueIsSet

    ListModel {
        id: classSeatsModel
        ListElement {
            name: qsTr("Econom class")
            seat: "Y"
        }
        ListElement {
            name: qsTr("Busines class")
            seat: "C"
        }
    }

    DataBase {
        id: database
    }

    Flickable {
        // ComboBox requires a flickable ancestor
        width: parent.width
        height: parent.height
        interactive: false

        Column {
            width: parent.width
            spacing: 0

            DialogHeader {
                acceptText: qsTr("Search")
                cancelText: qsTr("Cancel")
            }

            ListItem {
                id: originSelector
                contentHeight: Theme.itemSizeExtraSmall
                width: parent.width
                Label {
                    id: label
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    text: !origin?qsTr('Origin:'):originText
                    truncationMode: TruncationMode.Fade
                }

                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("SearchAirportDialog.qml"))

                    dialog.accepted.connect(function() {
                        originText = dialog.airportName + " (" + dialog.airportIATA + ")"
                        origin = dialog.cityIata
                        originAirport = dialog.airportName
                    })
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
                contentHeight: Theme.itemSizeExtraSmall
                width: parent.width
                Label {
                    id: labelDest
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    text: !destination?qsTr('Destination:'):destinationText
                    truncationMode: TruncationMode.Fade
                }

                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("SearchAirportDialog.qml"))

                    dialog.accepted.connect(function() {
                        destinationText = dialog.airportName + "(" + dialog.airportIATA + ")"
                        destination = dialog.cityIata
                        destinationAirport = dialog.airportName
                    })
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

            ValueButton {
                id: returnDateDate

                visible: !oneWay

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
                    }
                }
            }
            SectionHeader {
                text: qsTr("Childrens count")
            }
            Row {
                id: numberOfChildrens

                anchors.horizontalCenter: parent.horizontalCenter
                IconButton {
                    icon.source: "image://theme/icon-m-remove"
                    onClicked: {
                        childrens = parseInt(childrensCount.text)
                        if (childrens > 1) {
                            childrens = childrens - 1
                        }
                        childrensCount.text = childrens
                    }
                }
                Label {
                    id: childrensCount

                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width * 0.25
                    horizontalAlignment: Text.AlignHCenter
                    text: "0"
                }
                IconButton {
                    icon.source: "image://theme/icon-m-add"
                    onClicked: {
                        childrens = parseInt(childrensCount.text)
                        if (childrens < 10) {
                            childrens = childrens + 1
                        }
                        childrensCount.text = childrens
                    }
                }
            }
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
    }

    onAccepted: {
        var url = "http://api.travelpayouts.com/v1/flight_search"

        var postParms = {}
        postParms.marker = Utils.marker
        postParms.host = Utils.host
        postParms.user_ip = currentIp
        postParms.locale = database.language.toLowerCase()
        postParms.trip_class = seat
        postParms.passengers = {"adults": passengers, "children": childrens, "infants": 0}
        postParms.segments = [{"origin": origin, "destination": destination, "date": Utils.getFullDate(departureSelectedDate)}]

        if (returnDateValueIsSet) {
            postParms.segments.push({"origin": destination, "destination": origin, "date": Utils.getFullDate(returnSelectedDate)})
        }

        console.log(JSON.stringify(postParms))
        var s = Utils.createMD5(postParms)
        postParms.signature = s

        currentSearch["segments"] = [{"origin": origin, "destination": destination}]
        currentSearch["originName"] = originAirport
        currentSearch["destinationName"] = destinationAirport
        currentSearch["departureDate"] = departureSelectedDate
        currentSearch["passengers"] = {"adults": passengers, "children": 0, "infants": 0}
        currentSearch["directFlight"] = direct
        currentSearch["tripClass"] = seat
        currentSearch["roundTrip"] = false
        if (returnDateValueIsSet) {
            currentSearch["roundTrip"] = true
            currentSearch["returnDateDate"] = returnSelectedDate
            currentSearch["segments"].push({"origin": destination, "destination": origin})
        }
        var key = origin+"-"+destination
        database.storeFavorite(key, JSON.stringify(currentSearch))
        app.currentSearch = key

        app.newSearchAllowed = false

        pageStack.push(Qt.resolvedUrl("../pages/SearchResultsPage.qml"), {searchUrl: url, searchParams: postParms, directFlight: direct})
    }
}
