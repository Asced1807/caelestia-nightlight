pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Config
import qs.components
import qs.services
import asced1807.nightlight

// Bar entry: moon while the filter is on, sun while it is off.
// Hover opens the popout, click toggles, scroll makes it warmer/cooler.
Item {
    id: root

    property var settings
    property color colour: Colours.palette.m3secondary

    implicitWidth: icon.implicitWidth
    implicitHeight: icon.implicitHeight

    Component.onCompleted: NightLight.settings = settings
    onSettingsChanged: NightLight.settings = settings

    MaterialIcon {
        id: icon

        anchors.centerIn: parent

        animate: true
        text: NightLight.active ? "nightlight" : "light_mode"
        color: NightLight.active ? Colours.palette.m3primary : root.colour
        fill: NightLight.active ? 1 : 0
        fontStyle: Tokens.font.icon.medium
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: NightLight.toggle()
        onWheel: event => {
            if (event.angleDelta.y > 0)
                NightLight.nudge(true);
            else if (event.angleDelta.y < 0)
                NightLight.nudge(false);
        }
    }
}
