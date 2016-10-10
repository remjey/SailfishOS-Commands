import QtQuick 2.0
import Sailfish.Silica 1.0
import Process 1.0

Page {
    id: root

    property var command

    property bool running: false
    property bool terminated: false

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height

        VerticalScrollDecorator {}

        Column {
            id: content
            width: parent.width

            PageHeader {
                title: command.title
            }

            Item {
                height: customParam.height
                width: parent.width

                TextField {
                    id: customParam
                    anchors.left: parent.left
                    anchors.right: runButton.left
                    placeholderText: command.desc
                    label: command.desc
                    inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                    enabled: !running

                    EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                    EnterKey.onClicked: runCommand()
                }

                IconButton {
                    id: runButton
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.horizontalPageMargin
                    anchors.verticalCenter: customParam.verticalCenter
                    visible: !running
                    icon.source: "image://theme/icon-m-play"

                    onClicked: runCommand()
                }

                IconButton {
                    id: cancelButton
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.horizontalPageMargin
                    anchors.verticalCenter: customParam.verticalCenter
                    visible: running
                    icon.source: "image://theme/icon-m-clear"

                    onClicked: {
                        print("cancel:", terminated)
                        process.cancel(terminated);
                        terminated = true;
                    }
                }
            }

            Rectangle {
                height: Math.max(result.height + Theme.paddingLarge * 2, root.height - y)
                width: parent.width
                color: Theme.rgba("black", 0.5)

                Text {
                    id: result
                    textFormat: Text.PlainText
                    width: parent.width - Theme.horizontalPageMargin * 2
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    x: Theme.horizontalPageMargin
                    y: Theme.paddingLarge
                    height: implicitHeight
                    text: qsTr("The command has not been run yet.")
                    color: Theme.highlightColor
                }
            }
        }
    }

    Process {
        id: process

        onError: {
            result.text += "\n" + qsTr("[Error: %1]")
            .arg([
                     "Failed to start",
                     "Crashed",
                     "Timed out",
                     "Write error",
                     "Read error",
                     "Unknown error",
                 ][error])
            running = false;
        }

        onFinished: {
            setResultFont(false);
            result.text = filter(readAllAsString());

            if (command.showExitCode !== 2 && (command.showExitCode === 1 || getExitCode() !== 0)) {
                result.text += newLine() + qsTr("[Terminated with exit code %1]").arg(getExitCode());
            }

            if (terminated) {
                result.text += newLine() + qsTr("[Command was interrupted by user]");
            }

            running = false;
        }
    }

    function newLine() {
        if (command.filter >= 1) return "<br>";
        return "\n";
    }

    function runCommand() {
        running = true;
        terminated = false;
        var params = command.parameters.slice();
        params.forEach(function (s, i) {
            params[i] = s.replace(/%(.)/g, function (all, c) {
                if (c === "1") return customParam.text;
                if (c === "%") return "%";
                return all;
            });
        });

        setResultFont(true)
        result.text = qsTr("Command running...");
        process.start(command.program, params);
    }

    function setResultFont(system) {
        if (system || !command.monospace) {
            result.font.family = Theme.fontFamily
            result.font.pixelSize = (!system && command.smallerFont)
                    ? Theme.fontSizeExtraSmall
                    : Theme.fontSizeMedium;
        } else {
            result.font.family = "monospace"
            result.font.pixelSize = command.smallerFont ? Theme.fontSizeTiny : Theme.fontSizeExtraSmall
        }
        result.color = system ? Theme.highlightColor : Theme.primaryColor;
        result.textFormat = (!system && command.filter) ? Text.RichText : Text.PlainText;
    }

    function filter(s) {
        if (command.filter === 2) {
            return s.replace(/&|<|>/g, function (m) {
                switch (m) {
                case "&": return "&amp;";
                case "<": return "&lt;";
                case ">": return "&gt;";
                }
            }).replace(/(^|\n)((\t[^\n]*(\n|$))+)/g, function (m, m1, m2) {
                return "<ul><li><strong>" + m2.substr(1).split(/\n\t/).join("</strong><li><strong>") + "</strong></ul>";
            }).replace(/\n/, "<br>");
        } else {
            // Plain text or simple HTML
            return s;
        }
    }

    Component.onDestruction: {
        process.cancel(true);
    }
}

