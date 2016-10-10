import QtQuick 2.0
import Sailfish.Silica 1.0
import ".."

Dialog {
    id: root

    property var command: null

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height

        VerticalScrollDecorator {}

        Column {
            id: content
            width: parent.width

            DialogHeader {
                id: dialogHeader
                dialog: root
                title: qsTr("Edit Command")
                cancelText: qsTr("Cancel")
                acceptText: qsTr("Save")
            }

            TextField {
                id: commandTitle
                width: parent.width
                placeholderText: qsTr("Command title")
                label: placeholderText
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: commandProgram.focus = true
            }

            TextField {
                id: commandProgram
                width: parent.width
                placeholderText: qsTr("Program path")
                label: placeholderText
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: commandParameters.focus = true
            }

            TextArea {
                id: commandParameters
                width: parent.width
                height: Math.max(implicitHeight, Theme.itemSizeMedium * 2)
                placeholderText: qsTr("Parameters, one per line\nUse %1 to insert custom param")
                label: placeholderText
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: customParamDesc.focus = true
            }

            TextField {
                id: customParamDesc
                width: parent.width
                placeholderText: qsTr("Custom parameter description")
                label: placeholderText
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: customParamDesc.focus = false
            }

            ComboBox {
                id: outputFilter
                width: parent.width
                label: qsTr("Display output as")
                menu: ContextMenu {
                    MenuItem { text: qsTr("plain text") }
                    MenuItem { text: qsTr("simple HTML") }
                    MenuItem { text: qsTr("kangaroo") }
                }
            }

            ComboBox {
                id: showExitCode
                width: parent.width
                label: qsTr("Show exit code")
                menu: ContextMenu {
                    MenuItem { text: qsTr("if not zero") }
                    MenuItem { text: qsTr("always") }
                    MenuItem { text: qsTr("never") }
                }
            }

            TextSwitch {
                id: monospaceFont
                width: parent.width
                text: qsTr("Use a MonoSpace font")
            }

            TextSwitch {
                id: smallerFont
                width: parent.width
                text: qsTr("Use a smaller font")
            }

        }

    }

    acceptDestination: { return pageStack.previousPage() }
    acceptDestinationAction: PageStackAction.Pop

    onAccepted: {
        command.title = commandTitle.text;
        command.program = commandProgram.text.trim();
        command.parameters = commandParameters.text.trim().split(/\n/);
        command.desc = customParamDesc.text;
        command.showExitCode = showExitCode.currentIndex;
        command.monospace = monospaceFont.checked
        command.smallerFont = smallerFont.checked
        command.filter = outputFilter.currentIndex
        Model.saveCommand(command);
    }

    Component.onCompleted: {
        if (command) {
            commandTitle.text = command.title
            commandProgram.text = command.program
            commandParameters.text = command.parameters.join("\n");
            customParamDesc.text = command.desc;
            showExitCode.currentIndex = command.showExitCode || 0;
            monospaceFont.checked = command.monospace;
            smallerFont.checked = command.smallerFont;
            outputFilter.currentIndex = command.filter || 0;
        } else {
            dialogHeader.title = qsTr("New Command");
            commandTitle.focus = true;
            command = {};
        }
    }

}

