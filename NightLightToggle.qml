import QtQuick
import qs.components.controls
import qs.services
import asced1807.nightlight

// Quick toggle for the utilities drawer. Enable it with the id "nightLight"
// in utilities.quickToggles.
IconButton {
    id: root

    property var settings

    Component.onCompleted: NightLight.settings = settings
    onSettingsChanged: NightLight.settings = settings

    icon: "nightlight"
    checked: NightLight.active
    onClicked: NightLight.toggle()

    inactiveColour: Colours.layer(Colours.palette.m3surfaceContainerHighest, 2)
    fillWidth: true
    isToggle: true
    isRound: true
    shapeMorph: true
}
