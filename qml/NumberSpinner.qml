import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import harbour.counter 1.0

Item {
    id: spinner

    implicitWidth: digitWidth + 2 * horizontalMargins
    implicitHeight: digitHeight + 2 * verticalMargins
    width: implicitWidth
    height: implicitHeight

    property real verticalMargins
    property real horizontalMargins
    property bool animated: true
    property bool completed
    property bool sounds
    property alias hasBackground: background.visible
    property alias backgroundColor: background.color
    property alias cornerRadius: background.radius
    property alias interactive: view.interactive
    property alias color: sample.color
    property alias font: sample.font

    readonly property real digitWidth: Math.ceil(sample.paintedWidth)
    readonly property real digitHeight: Math.ceil(sample.paintedHeight)
    readonly property int number: view.actualNumber

    function setNumber(n) {
        view.currentIndex = (n + 5) % 10
    }

    Component.onCompleted: completed = true

    Loader {
        id: soundEffect

        active: sounds
        sourceComponent: Component {
            SoundEffect {
                source: "sounds/roll.wav"
            }
        }
    }

    Text {
        id: sample

        font {
            family: Theme.fontFamilyHeading
            pixelSize: Theme.fontSizeHuge
            bold: true
        }
        visible: false
        color: HarbourTheme.invertedColor(spinner.backgroundColor)
        text: "0"
    }
    Rectangle {
        id: background

        anchors.fill: parent
        radius: horizontalMargins/2
        color: Theme.primaryColor
        readonly property color color1: Theme.rgba(color, HarbourTheme.opacityFaint)
        gradient: Gradient {
            GradientStop { position: 0.0; color: HarbourTheme.lightOnDark ? background.color : background.color1 }
            GradientStop { position: 1.0; color: HarbourTheme.lightOnDark ? background.color1 : background.color }
        }
    }
    PathView {
        id: view

        clip: true
        width: digitWidth
        height: digitHeight
        anchors.centerIn: parent
        snapMode: PathView.SnapOneItem
        maximumFlickVelocity: Theme.maximumFlickVelocity
        highlightMoveDuration: animated ? 250 : 0
        model: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        pathItemCount: model.length
        offset: 5 // initial value (zero)
        path: Path {
            id: path

            startX: view.width/2
            startY: - 4 * view.height - view.height / 2

            PathLine {
                x: path.startX
                y: path.startY + view.pathItemCount * view.height
            }
        }
        delegate: Text {
            width: digitWidth
            height: digitHeight
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font: sample.font
            color: sample.color
            text: modelData
        }
        onCurrentIndexChanged: {
            if (moving) {
                if (soundEffect.item) {
                    soundEffect.item.play()
                }
            } else {
                updateActualNumber()
            }
        }
        onMovingChanged: if (!moving) view.updateActualNumber()
        function updateActualNumber() { actualNumber = (currentIndex + 5) % 10 }
        property int actualNumber
    }
}
