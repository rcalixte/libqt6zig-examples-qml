import QtQuick.Window
import QtQuick.Controls
import QtQuick.VirtualKeyboard

Window {
    color: "#eee"
    height: 600
    title: "Qt 6 Virtual Keyboard Example"
    visible: true
    width: 850

    TextField {
        focus: true
        anchors.centerIn: parent
        id: tf
        placeholderText: "type here"
        width: 300
    }

    InputPanel {
        id: ip
        width: parent.width
        y: active ? parent.height - height : parent.height
    }

    Shortcut {
        sequence: "Ctrl+Q"
        onActivated: Qt.quit()
    }
}
