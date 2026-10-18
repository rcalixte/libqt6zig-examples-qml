import QtQuick.Window
import QtWebEngine

Window {
    height: 750
    title: "Qt 6 WebEngine Example"
    visible: true
    width: 1024

    WebEngineView {
        anchors.fill: parent
        url: "https://github.com/rcalixte/libqt6zig-examples-qml"
    }

    Shortcut {
        sequence: "Ctrl+Q"
        onActivated: Qt.quit()
    }
}
