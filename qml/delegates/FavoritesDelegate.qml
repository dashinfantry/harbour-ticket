import QtQuick 2.2
import Sailfish.Silica 1.0

import "../pages/Utils.js" as Utils

ListItem {
    id: favoritesDelegate

    property alias airportOriginFullNameText: airportOriginFullName.text
    property alias airportDestinationFullNameText: airportDestinationFullName.text
    property string departureDate: ""
    property string origin: ""
    property string destination: ""

    clip: true

    Text {
        id: airportsIata
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        text: origin + " - " + destination
        font.pixelSize: Theme.fontSizeExtraSmall
        font.bold: true
        color: Theme.primaryColor
    }
    Text {
        id: airportOriginFullName
        anchors.right: airportsIata.horizontalCenter
        anchors.rightMargin: Theme.paddingSmall
        anchors.top: airportsIata.bottom
        text: "" //app.airportsInfo[fav_origin].name
        color: Theme.secondaryColor
        font.pixelSize: Theme.fontSizeTiny
    }
    Text {
        id: airportDestinationFullName
        anchors.left: airportsIata.horizontalCenter
        anchors.leftMargin: Theme.paddingMedium
        anchors.top: airportsIata.bottom
        text: "" //app.airportsInfo[fav_destination].name
        color: Theme.secondaryColor
        font.pixelSize: Theme.fontSizeTiny
    }
    Text {
        id: departureText
        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.top: airportDestinationFullName.bottom
        text: qsTr("Departure: ") + Utils.getFullDate(new Date(departureDate))
        color: Theme.secondaryColor
        font.pixelSize: Theme.fontSizeTiny
    }
}
