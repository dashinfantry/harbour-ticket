import QtQuick 2.2
import QtQuick.XmlListModel 2.0
import Sailfish.Silica 1.0

import "../utils/Utils.js" as Utils

import "../delegates"

Page {
    id: root

    property string xmlSource: ""

    BusyIndicator {
        id: busyIndicator
        running: true
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
    }

//    XmlListModel {
//        id: xmlModel
//        source: xmlSource
//        query: "/offers/offer/route"

//        XmlRole { name: "airline"; query: "../offer/@airline/string()" }
//        XmlRole { name: "offerTitle"; query: "../offer/@title/string()" }
//        XmlRole { name: "conditions"; query: "../conditions/string()" }
//        //"string-join(category, ',')"
////        XmlRole { name: "route"; query: "string-join(@*, ',')" }
//        //string(//actor[1]/@id)
////        XmlRole { name: "route"; query: "string(route/@from_iata)" }
//        XmlRole { name: "from_iata"; query: "../route/@from_iata/string()" }
//        XmlRole { name: "to_iata"; query: "@to_iata/string()" }
//    }

    PageHeader {
        id: pageHeader

        anchors.top: parent.top
        anchors.right: parent.right

        title: qsTr("Special offers")
    }

    XmlListModel {
        id: xmlModel
        source: xmlSource
        query: "//entry"
        namespaceDeclarations: "declare default element namespace 'http://www.w3.org/2005/Atom';" +
                               "declare namespace media='http://search.yahoo.com/mrss/';"

        XmlRole { name: "offerTitle"; query: "title/string()" }
        XmlRole { name: "summary"; query: "summary/div/string()" }
        XmlRole { name: "summary1"; query: "summary/div/p[2]/string()" }
        XmlRole { name: "iconSrc"; query: "media:thumbnail/@url/string()" }

        onStatusChanged: {
            if (status === XmlListModel.Ready) {
                busyIndicator.running = false
                for (var i = 0; i < count; i++)
                    console.log("summ", get(i).summary)
            }
        }
    }

    SilicaListView {
        anchors.top: pageHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        clip: true
        spacing: Theme.paddingSmall

//        header: PageHeader {
//            title: qsTr("Special offers")
//        }

        model: xmlModel

        delegate: ListItem {
//            anchors.margins: Theme.horizontalPageMargin

            contentHeight: airlaineIcon.height + airlineLabel.height + offerConditions.height

            Image {
                id: airlaineIcon

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin

                source: iconSrc
            }
            Text {
                id: airlineLabel

                anchors.top: airlaineIcon.bottom
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
//                anchors.top: parent.top
                text: offerTitle
                color: Theme.secondaryColor
            }
            Text {
                id: offerConditions

                anchors.top: airlineLabel.bottom
                width: parent.width
                text: summary + "\n" + summary1
                enabled: false
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
                color: Theme.secondaryColor
            }
        }
    }
}
