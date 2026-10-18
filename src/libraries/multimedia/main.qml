import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import QtMultimedia

ApplicationWindow {
    id: root
    title: "Qt 6 Multimedia Example"
    visible: true
    width: 1280; height: 750

    property alias source: player.source
    property int selectedNameFilter
    property list<string> nameFilters

    Component.onCompleted: if (source != "") player.play()

    MediaPlayer {
        id: player
        videoOutput: video
        audioOutput: AudioOutput {}
        onErrorOccurred: (error, errorString) => console.warn(errorString)
    }

    FileDialog {
        id: dialog
        nameFilters: root.nameFilters
        selectedNameFilter.index: root.selectedNameFilter
        onAccepted: { player.source = selectedFile; player.play() }
    }

    VideoOutput { id: video; anchors.fill: parent }

    footer: ToolBar {
        RowLayout {
            anchors.fill: parent
            Button { text: "Open"; onClicked: dialog.open() }
            Button {
                text: player.playing ? "Pause" : "Play"
                onClicked: player.playing ? player.pause() : player.play()
            }
            Slider {
                Layout.fillWidth: true
                to: player.duration
                value: player.position
                onMoved: player.position = value
            }
        }
    }

    Shortcut {
        sequence: "Ctrl+Q"
        onActivated: Qt.quit()
    }
}
