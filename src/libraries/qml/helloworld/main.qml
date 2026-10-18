import QtQuick.Window

Window {
    height: 300
    title: "Hello World"
    visible: true
    width: 400

    Text {
        anchors.centerIn: parent
        text: "Hello, World!"
        font.pixelSize: 32
    }

    Shortcut {
        sequence: "Ctrl+Q"
        onActivated: Qt.quit()
    }
}
