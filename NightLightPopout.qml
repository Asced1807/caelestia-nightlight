// caelestia-nightlight - Elvin Coronado Reyes (Asced1807)
// Licencia BSD 3-Clause

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import asced1807.nightlight

// Popout: on/off switch, intensity slider, presets and automatic/manual mode.
Item {
    id: root

    property var settings

    implicitWidth: 300
    implicitHeight: layout.implicitHeight + Tokens.padding.medium * 2

    Component.onCompleted: NightLight.settings = settings
    onSettingsChanged: NightLight.settings = settings

    ColumnLayout {
        id: layout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Tokens.spacing.medium

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.medium

            MaterialIcon {
                text: NightLight.active ? "nightlight" : "light_mode"
                color: NightLight.active ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                fill: 1
                fontStyle: Tokens.font.icon.medium
            }

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Night light")
                font: Tokens.font.body.builders.medium.weight(Font.Medium).build()
            }

            StyledSwitch {
                checked: NightLight.active
                onToggled: NightLight.toggle()
            }
        }

        StyledText {
            text: NightLight.active ? qsTr("%1 K · %2").arg(NightLight.temperature).arg(NightLight.describe(NightLight.temperature)) : qsTr("No filter (6500 K)")
            color: NightLight.active ? Colours.palette.m3primary : Colours.palette.m3onSurface
            font: Tokens.font.body.medium
        }

        CustomMouseArea {
            Layout.fillWidth: true
            implicitHeight: Tokens.padding.medium * 3

            onWheel: event => {
                if (event.angleDelta.y > 0)
                    NightLight.nudge(true);
                else if (event.angleDelta.y < 0)
                    NightLight.nudge(false);
            }

            StyledSlider {
                anchors.left: parent.left
                anchors.right: parent.right
                implicitHeight: parent.implicitHeight

                value: NightLight.intensity
                onInteraction: v => NightLight.setIntensity(v)
            }
        }

        RowLayout {
            Layout.fillWidth: true

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Neutral")
                color: Colours.palette.m3onSurfaceVariant
            }

            StyledText {
                text: qsTr("Warmer")
                color: Colours.palette.m3onSurfaceVariant
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            Repeater {
                model: [
                    {
                        label: qsTr("Reading"),
                        kelvin: 4500
                    },
                    {
                        label: qsTr("Night"),
                        kelvin: 3400
                    },
                    {
                        label: qsTr("Very warm"),
                        kelvin: 2700
                    }
                ]

                TextButton {
                    required property var modelData

                    Layout.fillWidth: true
                    type: TextButton.Tonal
                    text: modelData.label
                    internalChecked: NightLight.temperature === modelData.kelvin
                    onClicked: NightLight.setTemperature(modelData.kelvin)
                }
            }
        }

        StyledRect {
            Layout.fillWidth: true
            implicitHeight: modeColumn.implicitHeight + Tokens.padding.medium * 2
            color: Colours.tPalette.m3surfaceContainer
            radius: Tokens.rounding.medium

            ColumnLayout {
                id: modeColumn

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: Tokens.padding.medium
                spacing: Tokens.spacing.small

                StyledText {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    text: {
                        if (NightLight.manual)
                            return qsTr("Manual: stays like this at any time of day.");
                        if (!NightLight.followSun)
                            return qsTr("Automatic mode is off in the settings.");
                        return qsTr("Automatic: follows the sun.");
                    }
                    color: Colours.palette.m3onSurface
                }

                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("Sunrise %1  ·  Sunset %2").arg(NightLight.formatTime(NightLight.sunrise)).arg(NightLight.formatTime(NightLight.sunset))
                    color: Colours.palette.m3onSurfaceVariant
                }
            }
        }

        IconTextButton {
            Layout.fillWidth: true
            visible: NightLight.manual
            inactiveColour: Colours.palette.m3primaryContainer
            inactiveOnColour: Colours.palette.m3onPrimaryContainer
            verticalPadding: Tokens.padding.extraSmall
            text: qsTr("Back to automatic (%1 K now)").arg(NightLight.autoTemperature)
            icon: "schedule"

            onClicked: NightLight.useAutomatic()
        }
    }
}
