import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
    Column {
        anchors.fill: parent
        PageHeader {
            title: "About"
        }
        Label {
            width: parent.width
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Theme.horizontalPageMargin
            horizontalAlignment: Text.AlignLeft
            wrapMode: Text.WordWrap
            text: '<p>Travelpayouts is a pay-per-action travel affiliate program of JetRadar/Aviasales/Hotellook travel search,, including such brands as&nbsp;<a href="http://www.jetradar.com/">Jetradar.com</a>,&nbsp;<a href="http://hotellook.com/">Hotellook.com</a>,&nbsp;and <a href="http://www.aviasales.ru/">Aviasales.ru</a>:</p>'
            onLinkActivated: {
                Qt.openUrlExternally(link)
            }
        }
    }
}
