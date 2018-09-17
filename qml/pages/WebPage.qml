import QtQuick 2.2
import Sailfish.Silica 1.0

import "Utils.js" as Utils

Page {
    id: root

    property string pageUrl: "https://www.aviasales.ru/"

    SilicaWebView {
        id: webView

        anchors.fill: parent

        url: pageUrl
    }
}
