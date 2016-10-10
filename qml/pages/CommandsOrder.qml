import QtQuick 2.0
import Sailfish.Silica 1.0
import ".."

Page {
    id: root

    SilicaListView {
        id: list
        anchors.fill: parent
        model: ListModel {}

        header: PageHeader {
            title: qsTr("Change Commands Order")
        }

        VerticalScrollDecorator { flickable: list }

        move: Transition {
            NumberAnimation { properties: "y"; duration: 150; easing.type: Easing.OutQuad }
        }

        delegate: Item {
            id: listItem
            width: parent.width
            height: Theme.itemSizeMedium

            Label {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.right: moveUp.left

                color: Theme.highlightColor
                text: model.title
                truncationMode: TruncationMode.Fade
            }

            IconButton {
                id: moveUp
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: moveDown.left
                icon.source: "image://theme/icon-m-up"
                enabled: model.index > 0
                onClicked: {
                    Model.moveCommand(model.index, -1);
                    list.model.move(model.index, model.index - 1, 1);
                }
            }

            IconButton {
                id: moveDown
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                icon.source: "image://theme/icon-m-down"
                enabled: model.index < list.model.count - 1
                onClicked: {
                    Model.moveCommand(model.index, 1);
                    list.model.move(model.index, model.index + 1, 1)
                }
            }
        }
    }

    Component.onCompleted: {
        Model.listCommands().forEach(function (item) {
            list.model.append(item)
        })
    }
}
