import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

Kirigami.ApplicationWindow {
    height: 300
    id: root
    title: i18nc("@title:window", "Qt 6 Kirigami Example")
    width: 400

    pageStack.initialPage: Kirigami.Page {
        Controls.Label {
            anchors.centerIn: parent
            text: i18n("Hello World!")
        }
    }
}
