import QtQuick 2.4
import Sailfish.Silica 1.0

import "../utils/Utils.js" as Utils

ListItem {
    contentHeight:  logo.height + flightNumber.height + flightsRow.height + delayItem.height + Theme.itemSizeMedium
    width: parent.width
    enabled: false

    IconTextItem {
        id: delayItem

        anchors.top: parent.top
        height: delay > 0?Theme.itemSizeSmall:0
        visible: delay > 0
        enabled: false
        iconSource: "../images/wait.svg"
        title: qsTr("<b>Time to wait:</b> ") + Utils.fromMinToHours(delay)
    }

    Image {
        id: logo
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingMedium
        anchors.top: delayItem.bottom
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
        anchors.topMargin: Theme.paddingSmall
        font.pixelSize: Theme.fontSizeExtraSmall
        color: Theme.secondaryColor
        text: qsTr("<b>Flight number:</b> ") + carrier + flight_number + qsTr("<br><b>Aircraft:</b> ") + aircraft
    }
    Row {
        id: flightsRow

        anchors.top: flightNumber.bottom
        anchors.topMargin: Theme.paddingSmall
        width: Screen.width
        Item {
            id: originItem

            width: Screen.width * 0.5
            height: origin.height + departureDate.height//origin.height > departureDate.height ? origin.height + Theme.itemSizeSmall : departureDate.height + Theme.itemSizeSmall

            Text {
                id: departureDate

                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
//                anchors.top: origin.bottom
                anchors.topMargin: Theme.paddingSmall
                font.bold: true
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                text: Utils.fromUnixToTimeDateFormat(departure_time)
                wrapMode: "WordWrap"
                horizontalAlignment: Text.AlignLeft
            }

            Text {
                id: origin

                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                anchors.top: departureDate.bottom
                anchors.topMargin: Theme.paddingSmall
                font.pixelSize: Theme.fontSizeExtraSmall
                width: parent.width
                color: Theme.secondaryColor
                text: departure
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignLeft
            }

            Text {
                id: tripDuration
                anchors.horizontalCenter: departureDate.right
                anchors.verticalCenter: departureDate.verticalCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                text: qsTr("<b>Trip duration:</b><br>") + Utils.fromMinToHours(duration)
                horizontalAlignment: Text.AlignHCenter
            }
        }
        Item {
            id: destinationItem

            width: Screen.width * 0.45
            height: destination.height + arrivalDate.height

            Text {
                id: arrivalDate

                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
//                anchors.top: destination.bottom
                anchors.topMargin: Theme.paddingSmall
                font.bold: true
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                horizontalAlignment: Text.AlignRight
                text: Utils.fromUnixToTimeDateFormat(arrival_time)
            }
            Text {
                id: destination

                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                anchors.top: arrivalDate.bottom
                anchors.topMargin: Theme.paddingSmall
                font.pixelSize: Theme.fontSizeExtraSmall
                width: parent.width
                horizontalAlignment: Text.AlignRight
                color: Theme.secondaryColor
                text: arrival
                wrapMode: Text.WordWrap
            }
        }
    }
    Text {
        id: baggage

        anchors.top: flightsRow.bottom
        anchors.topMargin: Theme.paddingSmall
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingMedium
        width: Screen.width * 0.45
        color: Theme.secondaryColor
        font.bold: true
        font.pixelSize: Theme.fontSizeExtraSmall
        text: qsTr("Baggage: ") + Utils.bagageToString(flights_baggage)
        wrapMode: Text.WordWrap
    }
    Text {
        id: handbags

        anchors.top: flightsRow.bottom
        anchors.topMargin: Theme.paddingSmall
        anchors.right: parent.right
        width: Screen.width * 0.45
        color: Theme.secondaryColor
        font.bold: true
        font.pixelSize: Theme.fontSizeExtraSmall
        text: qsTr("Handbags: ") + Utils.bagageToString(flights_handbags)
        wrapMode: Text.WordWrap
    }
}
