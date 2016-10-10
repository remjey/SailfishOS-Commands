import QtQuick 2.0
import Sailfish.Silica 1.0
import ".."

Page {

    SilicaListView {
        id: list
        anchors.fill: parent
        model: ListModel {}

        PullDownMenu {
            MenuItem {
                text: qsTr("Change Order")
                onClicked: pageStack.push("CommandsOrder.qml")
            }

            MenuItem {
                text: qsTr("New Command")
                onClicked: pageStack.push("CommandEdit.qml")
            }
        }

        header: PageHeader {
            title: qsTr("Commands")
        }

        VerticalScrollDecorator { flickable: list }

        delegate: ListItem {
            id: listItem
            contentHeight: Theme.itemSizeMedium

            Label {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                text: model.title
                color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                truncationMode: TruncationMode.Fade
            }

            onClicked: {
                openCommand(model.id)
            }

            menu: ContextMenu {
                id: listItemMenu
                MenuItem {
                    text: qsTr("Edit")
                    onClicked: {
                        pageStack.push("CommandEdit.qml", { command: Model.getCommand(model.id)} );
                    }
                }

                MenuItem {
                    text: qsTr("Delete")
                    onClicked: {
                        listItem.remorseAction(qsTr("Delete Command"), function () {
                            Model.deleteCommand(model.id);
                        });
                    }
                }
            }
        }
    }

    function openCommand(id) {
        var command = Model.getCommand(id)
        pageStack.push("CommandRun.qml", { command: command });
    }

    function updateCommands() {
        list.model.clear()
        Model.listCommands().forEach(function (item) {
            list.model.append(item)
        })
    }

    Connections {
        target: Model
        onCommandsChanged: updateCommands();
    }

    Component.onCompleted: updateCommands();
}

