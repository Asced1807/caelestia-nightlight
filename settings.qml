// caelestia-nightlight - Elvin Coronado Reyes (Asced1807)
// Licencia BSD 3-Clause

import Caelestia.Plugins

// Settings for the night light plugin. The plugin system instantiates this and
// passes it to every entry point as `settings`; do not instantiate it manually.
SettingsObject {
    // Automatic mode
    property bool followSun: true
    property int nightTemperature: 3400
    property int transitionMinutes: 60

    // Location used to compute sunrise/sunset. With useTimezone the longitude is
    // guessed from the system timezone (like f.lux does) and the latitude below is used.
    property bool useTimezone: true
    property real latitude: 30
    property real longitude: 0

    // Manual adjustments
    property int step: 250
    property int minTemperature: 1500

    SettingMeta on followSun {
        label: qsTr("Follow the sun")
        description: qsTr("Warm the screen automatically between sunset and sunrise")
        inputType: SettingMeta.Switch
    }

    SettingMeta on nightTemperature {
        label: qsTr("Night temperature (K)")
        description: qsTr("Colour temperature used at night. Lower is warmer")
        min: 1500
        max: 6000
        step: 50
        inputType: SettingMeta.Slider
    }

    SettingMeta on transitionMinutes {
        label: qsTr("Transition length (minutes)")
        description: qsTr("How long the fade around sunset and sunrise lasts")
        min: 0
        max: 180
        step: 5
        inputType: SettingMeta.SpinBox
    }

    SettingMeta on useTimezone {
        label: qsTr("Guess longitude from timezone")
        description: qsTr("Turn off to use the exact longitude below")
        inputType: SettingMeta.Switch
    }

    SettingMeta on latitude {
        label: qsTr("Latitude")
        description: qsTr("Degrees, north positive (e.g. 40.4 for Madrid)")
        min: -90
        max: 90
        step: 0.1
        inputType: SettingMeta.SpinBox
    }

    SettingMeta on longitude {
        label: qsTr("Longitude")
        description: qsTr("Degrees, east positive (e.g. -3.7 for Madrid)")
        min: -180
        max: 180
        step: 0.1
        inputType: SettingMeta.SpinBox
    }

    SettingMeta on step {
        label: qsTr("Scroll step (K)")
        description: qsTr("How much each scroll notch changes the temperature")
        min: 50
        max: 1000
        step: 50
        inputType: SettingMeta.SpinBox
    }

    SettingMeta on minTemperature {
        label: qsTr("Warmest allowed (K)")
        min: 1000
        max: 4000
        step: 100
        inputType: SettingMeta.SpinBox
    }
}
