import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import harbour.counter 1.0

CoverBackground {
    id: cover

    readonly property url plusIconSource: Qt.resolvedUrl("images/" + (HarbourTheme.darkOnLight ? "cover-plus-dark.svg" :  "cover-plus.svg"))
    readonly property url minusIconSource: Qt.resolvedUrl("images/" + (HarbourTheme.darkOnLight ? "cover-minus-dark.svg" :  "cover-minus.svg"))
    property alias coverItem: coverItemLoader.item

    Loader {
        id: coverItemLoader

        anchors.fill: cover
        source: Qt.resolvedUrl(CounterSettings.coverItem)
    }

    Binding {
        target: coverItem
        property: "model"
        value: coverModel
    }

    function inc(pos) {
        coverItem.inc(pos);
        if (plusSound.item) {
            plusSound.item.play()
        }
        if (buzz.item) {
            buzz.item.play()
        }
    }

    function dec(pos) {
        if (coverItem.dec(pos)) {
            if (minusSound.item) {
                minusSound.item.play()
            }
            if (buzz.item) {
                buzz.item.play()
            }
        }
    }

    CounterFavoritesModel {
        id: coverModel

        sourceModel: CounterListModel
    }

    Loader {
        id: buzz

        active: CounterSettings.vibraEnabled
        source: "Buzz.qml"
    }

    Loader {
        id: plusSound

        active: CounterSettings.soundsEnabled
        sourceComponent: Component {
            SoundEffect { source: "sounds/plus.wav" }
        }
    }

    Loader {
        id: minusSound

        active: CounterSettings.soundsEnabled
        sourceComponent: Component {
            SoundEffect { source: "sounds/minus.wav" }
        }
    }

    CoverActionList {
        enabled: coverItem && coverItem.count === 1
        CoverAction {
            iconSource: cover.minusIconSource
            onTriggered: cover.dec(0)
        }
        CoverAction {
            iconSource: cover.plusIconSource
            onTriggered: cover.inc(0)
        }
    }

    CoverActionList {
        enabled: coverItem && coverItem.count > 1
        CoverAction {
            iconSource: cover.plusIconSource
            onTriggered: cover.inc(0)
        }
        CoverAction {
            iconSource: cover.plusIconSource
            onTriggered: cover.inc(1)
        }
    }
}
