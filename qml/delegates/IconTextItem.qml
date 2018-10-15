import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    id: root

    property string iconSource: "image://theme/icon-m-gps"
    property string title: ""

    property alias fontSize: label.font.pixelSize

    height: Theme.itemSizeSmall

    Image {
        id: icon

        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.verticalCenter: parent.verticalCenter

        height: Theme.iconSizeMedium
        width: Theme.iconSizeMedium
        source: iconSource
    }

    Label {
        id: label

        anchors.left: icon.right
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.right: parent.right
        anchors.rightMargin: Theme.horizontalPageMargin
        anchors.verticalCenter: parent.verticalCenter

        text: title
        color: Theme.secondaryColor
        wrapMode: Text.WordWrap
        truncationMode: TruncationMode.Fade
        maximumLineCount: 2
    }
}
