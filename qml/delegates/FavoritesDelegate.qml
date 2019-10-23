import QtQuick 2.2
import Sailfish.Silica 1.0

import "../utils/Utils.js" as Utils

ListItem {
    id: favoritesDelegate

    property alias airportOriginFullNameText: airportOriginFullName.text
    property alias airportDestinationFullNameText: airportDestinationFullName.text
    property string departureDate: ""
    property string origin: ""
    property string destination: ""

    clip: true
    contentHeight: Theme.itemSizeLarge

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
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingMedium
        anchors.right: airportsIata.horizontalCenter
        anchors.rightMargin: Theme.paddingSmall
        anchors.top: airportsIata.bottom
        width: parent.width * 0.5
        text: "" //app.airportsInfo[fav_origin].name
        color: Theme.secondaryColor
        font.pixelSize: Theme.fontSizeTiny
        maximumLineCount: 2
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignRight
    }
    Text {
        id: airportDestinationFullName
        anchors.left: airportsIata.horizontalCenter
        anchors.leftMargin: Theme.paddingMedium
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingSmall
        anchors.top: airportsIata.bottom
        width: parent.width * 0.5
        text: "" //app.airportsInfo[fav_destination].name
        color: Theme.secondaryColor
        font.pixelSize: Theme.fontSizeTiny
        maximumLineCount: 2
        wrapMode: Text.WordWrap
    }
    Text {
        id: departureText
        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.top: airportOriginFullName.bottom
        anchors.topMargin: Theme.paddingSmall
        text: qsTr("Departure: ") + Utils.getFullDate(new Date(departureDate))
        color: Theme.secondaryColor
        font.pixelSize: Theme.fontSizeTiny
    }
}
