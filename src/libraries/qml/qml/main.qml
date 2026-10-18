import QtQuick.Window

Window {
    height: 480
    title: "Qt 6 QML Example"
    visible: true
    width: 640

    ListView {
        anchors.fill: parent
        model: my_model
        delegate: Row {
            spacing: 10
            Text { text: display }
        }
    }

    Shortcut {
        sequence: "Ctrl+Q"
        onActivated: Qt.quit()
    }
}
