import QtQuick

Window {
    height: 250
    title: "Qt 6 ClassInfo Example"
    visible: true
    width: 550

    required property string description

    Text {
        anchors.centerIn: parent
        font.pointSize: 24
        text: description
    }

    Shortcut {
        sequence: "Ctrl+Q"
        onActivated: Qt.quit()
    }
}
