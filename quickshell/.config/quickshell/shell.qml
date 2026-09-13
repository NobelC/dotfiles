import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    PanelWindow {
        id: win
        visible: true
        anchors.left: true
        anchors.right: true
        anchors.top: true
        anchors.bottom: true
        color: "transparent"

        property var themes: []

        // Hyprland's environment lacks ~/.local/bin: every process spawned
        // from a keybind needs the PATH exported explicitly.
        property string pathPrefix: "export PATH=\"$HOME/.local/bin:$PATH\"; "

        Process {
            id: modelProc
            command: ["sh", "-c", win.pathPrefix + "theme-carousel-model.sh"]
            stdout: StdioCollector {
                onStreamFinished: win.themes = JSON.parse(text)
            }
            running: true
        }

        Process {
            id: applyProc
            stdout: StdioCollector {
                onStreamFinished: Qt.quit()
            }
        }

        function applyTheme(t) {
            applyProc.command = ["sh", "-c", win.pathPrefix +
                "aether --import-colors-toml '" + t.colors + "' --wallpaper '" + t.wallpaper + "'"]
            applyProc.running = true
        }

        Rectangle {
            anchors.fill: parent
            color: "#66000000"
            MouseArea {
                anchors.fill: parent
                onClicked: Qt.quit()
            }
        }

        GridView {
            id: grid
            anchors.centerIn: parent
            width: 1020
            height: 520
            cellWidth: 330
            cellHeight: 240
            model: win.themes
            clip: true
            focus: true

            Keys.onEscapePressed: Qt.quit()

            delegate: Rectangle {
                width: 310
                height: 220
                radius: 14
                color: "#120e1e"
                border.color: grid.currentIndex === index ? "#ccabf4" : "#2a2438"
                border.width: grid.currentIndex === index ? 2 : 1

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        grid.currentIndex = index
                        win.applyTheme(modelData)
                    }
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 6

                    Image {
                        width: 294
                        height: 166
                        fillMode: Image.PreserveAspectCrop
                        clip: true
                        source: "file://" + modelData.thumb
                    }

                    Text {
                        width: 294
                        text: modelData.name
                        color: grid.currentIndex === index ? "#ccabf4" : "#8a7fa0"
                        elide: Text.ElideMiddle
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 13
                    }
                }
            }
        }
    }
}
