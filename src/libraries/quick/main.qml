import QtQuick

Rectangle {
    color: "#1e1e1e"
    height: 300
    id: root
    width: 400

    property int count: 0
    signal tapped(string message)

    function reset() {
        count = 0
    }

    Rectangle {
        height: 80
        width: 80
        anchors.horizontalCenter: parent.horizontalCenter
        color: "#eb915c"
        radius: 10
        y: 40
        RotationAnimation on rotation {
            duration: 3000
            from: 0
            loops: Animation.Infinite
            to: 360
        }
    }

    Text {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 60
        color: "white"
        font.pixelSize: 24
        text: "Clicks: " + root.count
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.count++
            root.tapped("### QML was clicked " + root.count + " time(s).")
        }
    }

    Shortcut {
        sequence: "Ctrl+Q"
        onActivated: Qt.quit()
    }
}
