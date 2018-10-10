import QtQuick 2.6
import Sailfish.Silica 1.0

import "../utils/Utils.js" as Utils
import "../utils"

Dialog {
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

    canAccept: true //origin.length >= 2&&destination.length >= 2&&departureDateValueIsSet

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

    ListModel {
        id: segmentsModel
    }

    DataBase {
        id: database
    }

    QtObject {
        id: internal

        property string origin
        property string destination
        property string originAirport
        property string destinationAirport
        property date departureDate: new Date()
        property string dateText
    }

    Component {
        id: segmentPoint

        Column {
            width: parent.width
            spacing: 0

            ListItem {
                id: originSelector
                contentHeight: Theme.itemSizeExtraSmall
                width: parent.width
                Label {
                    id: labelOrigin
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr('Origin:')
                }

                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("SearchAirportDialog.qml"))

                    dialog.accepted.connect(function() {
                        labelOrigin.text = dialog.airportName + " (" + dialog.airportIATA + ")"
                        internal.origin = dialog.cityIata
                        internal.originAirport = dialog.airportName + " (" + dialog.airportIATA + ")"
                    })
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
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr('Destination:')
                }

                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("SearchAirportDialog.qml"))

                    dialog.accepted.connect(function() {
                        labelDest.text = dialog.airportName + "(" + dialog.airportIATA + ")"
                        internal.destination = dialog.cityIata
                        internal.destinationAirport = dialog.airportName + "(" + dialog.airportIATA + ")"
                    })
                }
            }

            ValueButton {
                id: departureDate

                function openDateDialog() {
                    var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", {
                                    date: internal.departureDate
                                 })

                    dialog.accepted.connect(function() {
                        var currDate = new Date()
                        if (currDate <= dialog.date) {
                            internal.dateText = dialog.dateText
                            departureDate.value = dialog.dateText
                            internal.departureDate = dialog.date
//                            departureDateValueIsSet = true
                        }

                        //Depart date can not be from past
                    })
                }

                label: qsTr("Departure date:")
                value: departureDateValue
                width: parent.width
                onClicked: openDateDialog()
            }
            Item {
                id: buttonsRow

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: Theme.horizontalPageMargin
                width: parent.width
                height: cancelButton.height
                Button {
                    id: cancelButton

                    anchors.left: parent.left
                    text: "Cancel"

                    onClicked: {
                        drawer.hide()
                    }
                }
                Button {
                    id: acceptButton

                    anchors.right: parent.right
                    text: "Accept"

                    onClicked: {
                        segmentsModel.append({originIata: internal.origin,
                                                 destinationIata: internal.destination,
                                                 date: internal.departureDate,
                                                 dateFormatted: internal.dateText,
                                                 originFullText: internal.originAirport,
                                                 destinationFullText: internal.destinationAirport
                                             })
                        drawer.hide()
                    }
                }
            }
        }
    }

    Drawer {
        id: drawer

//        open: true
        anchors.fill: parent
        dock: Dock.Bottom
        backgroundSize: 400

        background: SilicaListView {
            anchors.fill: parent
            model: 1
            delegate: segmentPoint
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

            SilicaListView {

                height: Theme.itemSizeMedium * 3
                contentHeight: Theme.itemSizeMedium * 3
                width: parent.width
                model: segmentsModel
                delegate: ListItem {
                    contentHeight: Theme.itemSizeMedium

                    Text {
                        anchors.top: parent.top
                        anchors.topMargin: Theme.paddingSmall
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.horizontalPageMargin
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.horizontalPageMargin
                        width: parent.width
                        color: Theme.primaryColor
                        wrapMode: Text.WordWrap
                        text: originFullText + " - " + destinationFullText
                    }
                    Text {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: Theme.paddingMedium
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.horizontalPageMargin
                        color: Theme.primaryColor
                        text: dateFormatted
                    }
                }

            footer: StartScreenItem {
                width: parent.width
                title: "Add segment"
                iconSource: "image://theme/icon-m-add"

                onClicked: {
                    drawer.show()
                }
            }
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
                        console.log(childrens)
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
                        console.log(childrens)
                    }
                }
            }


            ComboBox {
                id: classSelector

                width: parent.width
                label: qsTr('Trip class:')
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
        postParms.segments = []
        console.log("Model count", segmentsModel.count)
        for (var i = 0; i < segmentsModel.count; i++) {
            console.log("Add segment", JSON.stringify(segmentsModel.get(i)))
            postParms.segments.push({"origin": segmentsModel.get(i).originIata, "destination": segmentsModel.get(i).destinationIata, "date": Utils.getFullDate(segmentsModel.get(i).date)})
        }


//        if (returnDateValueIsSet) {
//            postParms.segments.push({"origin": destination, "destination": origin, "date": Utils.getFullDate(returnSelectedDate)})
//        }

        console.log(JSON.stringify(postParms))
        var s = Utils.createMD5(postParms)
        postParms.signature = s

        app.newSearchAllowed = false

        console.log("postParams", JSON.stringify(postParms))
        pageStack.push(Qt.resolvedUrl("../pages/SearchResultsPage.qml"), {searchUrl: url, searchParams: postParms})
    }
}
