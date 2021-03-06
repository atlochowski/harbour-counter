import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import harbour.counter 1.0

import "harbour"

CoverBackground {
    id: cover

    readonly property string plusIconSource: Qt.resolvedUrl("images/" + (HarbourTheme.darkOnLight ? "cover-plus-dark.svg" :  "cover-plus.svg"))
    readonly property string minusIconSource: Qt.resolvedUrl("images/" + (HarbourTheme.darkOnLight ? "cover-minus-dark.svg" :  "cover-minus.svg"))

    Row {
        id: row

        x: (repeater.visibleCount === 1) ? Math.round((parent.width - width)/2) : Theme.paddingMedium
        height: parent.height
        spacing: Theme.paddingMedium
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
            id: repeater

            readonly property int visibleCount: Math.min(repeater.count,2)
            model: CounterFavoritesModel { sourceModel: CounterListModel }
            delegate: Item {
                id: counterDelegate

                height: row.height
                width: (repeater.visibleCount === 1) ?
                    Math.max(numberLabel.implicitWidth + 2 * Theme.paddingMedium, Math.round(cover.width*0.6)) :
                    maxWidth

                readonly property real maxWidth: Math.floor((cover.width - 2 * Theme.paddingMedium - (repeater.visibleCount - 1) * row.spacing)/repeater.visibleCount)

                Loader {
                    id: plusSound

                    active: model.sounds
                    sourceComponent: Component { SoundEffect { source: "sounds/plus.wav" } }
                }
                Loader {
                    id: minusSound

                    active: model.sounds
                    sourceComponent: Component { SoundEffect { source: "sounds/minus.wav" } }
                }
                Label {
                    anchors {
                        top: parent.top
                        topMargin: Theme.paddingLarge
                        horizontalCenter: parent.horizontalCenter
                    }
                    text: model.title
                    width: Math.min(implicitWidth, parent.width)
                    truncationMode: TruncationMode.Fade
                    horizontalAlignment: Text.AlignLeft
                    color: Theme.highlightColor
                    textFormat: Text.PlainText
                }
                Rectangle {
                    id: background

                    anchors.centerIn: parent
                    width: counterDelegate.width
                    height: width
                    radius: width/2
                    color: Theme.rgba(Theme.primaryColor, HarbourTheme.opacityHigh)
                    readonly property color color1: Theme.rgba(Theme.primaryColor, HarbourTheme.opacityFaint)
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: HarbourTheme.lightOnDark ? background.color : background.color1 }
                        GradientStop { position: 1.0; color: HarbourTheme.lightOnDark ? background.color1 : background.color }
                    }
                }
                HarbourFitLabel {
                    id: numberLabel

                    opacity: 0
                    width: counterDelegate.maxWidth - 2 * Theme.paddingLarge
                    height: counterDelegate.height - 2 * Theme.paddingLarge
                    anchors.centerIn: parent
                    maxFontSize: Theme.fontSizeHuge
                    text: model.value
                    font {
                        family: Theme.fontFamilyHeading
                        bold: true
                    }
                }
                NumberPanel {
                    anchors.centerIn: parent
                    number: model.value
                    interactive: false
                    animated: false
                    hasBackground: false
                    color: HarbourTheme.invertedColor(Theme.primaryColor)
                    horizontalMargins: 0
                    count: numberLabel.text.length
                    font: numberLabel.font
                    Component.onCompleted: animated = true
                }
                function inc() {
                    model.value++
                    if (plusSound.item) {
                        plusSound.item.play()
                    }
                }
                function dec() {
                    if (model.value > 0) {
                        model.value--
                        if (minusSound.item) {
                            minusSound.item.play()
                        }
                    }
                }
            }
        }
    }

    CoverActionList {
        enabled: repeater.count === 1
        CoverAction {
            iconSource: cover.minusIconSource
            onTriggered: repeater.itemAt(0).dec()
        }
        CoverAction {
            iconSource: cover.plusIconSource
            onTriggered: repeater.itemAt(0).inc()
        }
    }

    CoverActionList {
        enabled: repeater.count > 1
        CoverAction {
            iconSource: cover.plusIconSource
            onTriggered: repeater.itemAt(0).inc()
        }
        CoverAction {
            iconSource: cover.plusIconSource
            onTriggered: repeater.itemAt(1).inc()
        }
    }
}
