import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property string imageType:  "Grids"
    property string steamAppId: ""

    readonly property int cellW: imageType === "Heroes" ? 360 : imageType === "Icons" ? 130 : imageType === "Logos" ? 250 : 160
    readonly property int cellH: imageType === "Heroes" ? 175 : imageType === "Icons" ? 130 : imageType === "Logos" ? 115 : 225

    readonly property int gap: 12

    Rectangle {//toast
        id: toast
        anchors.bottom: loadMoreBar.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 10
        width: toastText.implicitWidth + 32
        height: 38
        radius: 6
        color: steamGrid.downloadStatus.startsWith("OK") ? "#1a9fff" : "#c0392b"
        visible: opacity > 0
        opacity: 0
        z: 10

        Text {
            id: toastText
            anchors.centerIn: parent
            text: steamGrid.downloadStatus
            color: "white"
            font.pixelSize: 13
            font.bold: true
        }

        Connections {
            target: steamGrid
            function onDownloadStatusChanged() {
                if (steamGrid.downloadStatus === "") return
                toast.opacity = 1
                toastTimer.restart()
            }
        }
        Timer { id: toastTimer; interval: 3000; onTriggered: toast.opacity = 0 }
        Behavior on opacity { NumberAnimation { duration: 300 } }
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: steamGrid.isLoadingImages
        visible: running
    }

    Text {
        anchors.centerIn: parent
        text: qsTr("Search the game and choose the image type")
        color: theme.font
        font.pixelSize: 16
        visible: !steamGrid.isLoadingImages && steamGrid.imagesModel.length === 0
    }

 Flow {
    anchors.fill: parent; anchors.margins: gap; spacing: gap
    visible: steamGrid.isLoadingImages && steamGrid.imagesModel.length === 0

    readonly property int totalMemes: 8 

    Repeater {
        model: 6
        Rectangle {
            width: root.cellW
            height: root.cellH + 52
            color: theme.textfield_c
            radius: 6
            clip: true
            border.color: theme.frame
            border.width: 2

            Image {
                anchors.fill: parent
                
                source: {
                    let randomNumber = Math.floor(Math.random() * parent.parent.totalMemes) + 1;
                    return "qrc:/SteamApp/resources/skeleton/" + randomNumber + ".png";
                }

                fillMode: Image.PreserveAspectCrop
                opacity: 0.2
                
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { from: 0.1; to: 0.3; duration: 1000; easing.type: Easing.InOutQuad }
                    NumberAnimation { from: 0.3; to: 0.1; duration: 1000; easing.type: Easing.InOutQuad }
                }
            }
        }
    }
}

    GridView {
        id: grid
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: loadMoreBar.top
            margins: root.gap
            rightMargin: root.gap + 10
        }
        visible: !steamGrid.isLoadingImages
        clip: true
        

        cellWidth:  root.cellW + root.gap
        cellHeight: root.cellH + 52 + root.gap

        model: steamGrid.imagesModel

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }

        delegate: CsComponent {
            type: root.imageType
            imageSource: modelData.url
            width: root.cellW
            height: root.cellH + 52

            onDownloadClicked: {
                steamGrid.downloadAndReplace(modelData.url, root.steamAppId, root.imageType)
            }
        }
    }

    Rectangle {
        id: loadMoreBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: steamGrid.imagesModel.length > 0 ? 52 : 0
        visible: height > 0
        color: theme.back_second

        Behavior on height { NumberAnimation { duration: 200 } }

        Text {
            anchors.centerIn: parent
            text: qsTr("No Results")
            color: theme.font
            font.pixelSize: 13
            visible: steamGrid.imagesModel.length === 0 && !steamGrid.isLoadingImages
        }

        CsButton {
            anchors.centerIn: parent
            btnText: qsTr("Load More")
            width: 180
            height: 34
            visible: steamGrid.hasMoreImages && !steamGrid.isLoadingImages
            onClicked: steamGrid.loadMoreImages()
        }

        BusyIndicator {
            anchors.centerIn: parent
            scale: 0.6
            running: steamGrid.isLoadingImages && steamGrid.imagesModel.length > 0
            visible: running
        }
    }
}
