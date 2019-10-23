import QtQuick 2.2
import Sailfish.Silica 1.0

import "../utils/"
import "../utils/Utils.js" as Utils

ListItem {
    id: ticketInfoItem
    property string search_id
    property string orig: ""
    property string airlineIata
    property string date_from: ""
    property string date_to: ""
    property string ticket_price: ""
    property string fly_duration: ""
    property string _currency: ""
    property int transfers_count: 0
    property int local_departure: 0
    property int local_arrival: 0
    property int unified_price: 0

    property variant proposal: ({})
    property variant airports: ({})
    property variant airlines: ({})

    //    property bool   direct: false

    property variant currencyRatesInfo: ({})

//    height: Theme.itemSizeSmall + orig_dest.height + ticketPrice.height
    contentHeight:  Theme.itemSizeSmall + orig_dest.height + ticketPrice.height
    width: parent.width

    DataBase {
        id: database
    }

    QtObject {
        id: internal

        property string flyNumber: ""
        property string arrival_date: ""
        property string departure_date: ""

    }

    Component.onCompleted: {
        var flyNumbers = []
        var segment = proposal.segment[0]
        for (var id in segment.flight) {
            var t = segment.flight[id].operating_carrier + segment.flight[id].number
            flyNumbers.push(t)
        }
        internal.flyNumber = flyNumbers.filter(Utils.onlyUnique).join(" - ")
//        internal.departure_date = Utils.fromUnixToShortFormat(segment.flight[0].local_departure_timestamp, database.language)
//        internal.arrival_date = Utils.fromUnixToShortFormat(segment.flight[0].local_arrival_timestamp, database.language)
    }

    Label {
        id: orig_dest
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        font.bold: true
        text: orig
        horizontalAlignment: Text.AlignHCenter
    }

    Image {
        id: logo
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingMedium
        anchors.top: orig_dest.bottom
        //        height: Theme.iconSizeLarge
        width: Theme.iconSizeExtraLarge
        source: airlineIata?"http://pics.avs.io/264/87/"+ airlineIata +".png":""
        //source: iata?"http://ios.aviasales.ru/logos/xxhdpi/"+ iata +".png":""
        fillMode: Image.PreserveAspectFit
    }

    Label {
        anchors.left: logo.right
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.top: logo.top
        color: Theme.secondaryColor
        text: airlines[airlineIata].name
    }

    Column {
        anchors.top: logo.bottom
        anchors.left: parent.left
        anchors.right: ticketPrice.left
        anchors.margins: Theme.paddingMedium
        spacing: Theme.paddingSmall
        Row {
            spacing: Theme.horizontalPageMargin
            Text {
                font.pixelSize: Theme.fontSizeTiny
                color: Theme.secondaryColor
                text: Utils.fromUnixToShortFormat(local_departure, database.language) //internal.departure_date
            }
            Text {
                font.pixelSize: Theme.fontSizeTiny
                color: Theme.secondaryColor
                text: Utils.fromUnixToShortFormat(local_arrival, database.language) //internal.arrival_date
            }
        }
        Row {
            spacing: Theme.horizontalPageMargin
            Text {
                font.pixelSize: Theme.fontSizeTiny
                color: Theme.secondaryColor
                text: qsTr("<b>Trip duration:</b> ") + Utils.fromMinToHours(fly_duration)
            }
            Text {
                font.pixelSize: Theme.fontSizeTiny
                color: Theme.secondaryColor
                text: qsTr("<b>Stops:</b> ") + (transfers_count > 0?transfers_count:qsTr("Direct"))
            }
        }
    }

    Label {
        id: ticketPrice
        anchors.top: logo.verticalCenter
        anchors.topMargin: Theme.paddingLarge
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingMedium
        font.bold: true
        color: Theme.highlightColor
        text: ticket_price
        font.pixelSize: Theme.fontSizeLarge
        horizontalAlignment: Text.AlignHCenter
    }
    Separator {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }

    onClicked: {
        pageStack.push(Qt.resolvedUrl("../pages/TicketPage.qml"), {
                           "ticket": proposal,
                           "_search_id": search_id,
                           "currencyRates": currencyRatesInfo,
                           "_currency": _currency,
                           "airports": airports,
                           "airlines": airlines,
                           "unified_price": unified_price
                       })
    }
}

