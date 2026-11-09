pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.utils

// Night light service: decides the colour temperature and applies it through hyprsunset.
//
// Automatic mode follows the sun (NOAA sunrise/sunset equations) with a linear fade
// centred on sunrise and sunset. Manual mode keeps whatever the user picked, at any
// time of day, until they go back to automatic. Manual state survives restarts.
Singleton {
    id: root

    readonly property int day: 6500 // 6500 K == no filter (hyprsunset identity)

    // Injected by the entry points (the plugin system only hands settings to them)
    property var settings: null

    readonly property bool followSun: settings?.followSun ?? true
    readonly property int nightTemperature: settings?.nightTemperature ?? 3400
    readonly property int transitionMinutes: settings?.transitionMinutes ?? 60
    readonly property int step: settings?.step ?? 250
    readonly property int minTemperature: settings?.minTemperature ?? 1500
    readonly property real latitude: settings?.latitude ?? 30
    readonly property real longitude: (settings?.useTimezone ?? true) ? -new Date().getTimezoneOffset() / 4 : (settings?.longitude ?? 0)

    // Persistent state
    property bool manual: false
    property int manualTemperature: day
    property int lastOnTemperature: nightTemperature

    // Derived
    property int autoTemperature: day
    property date sunrise: new Date()
    property date sunset: new Date()
    readonly property int temperature: manual ? manualTemperature : autoTemperature
    readonly property bool active: temperature < day
    // 0 = no filter, 1 = warmest allowed
    readonly property real intensity: Math.max(0, Math.min(1, (day - temperature) / (day - minTemperature)))

    property int applied: -1
    property bool hyprsunsetChecked: false

    // ------------------------------------------------------------------ public API

    function setTemperature(t: int): void {
        manualTemperature = Math.max(minTemperature, Math.min(day, Math.round(t / 50) * 50));
        if (manualTemperature < day)
            lastOnTemperature = manualTemperature;
        manual = true;
        save();
    }

    function setIntensity(v: real): void {
        setTemperature(day - v * (day - minTemperature));
    }

    function nudge(warmer: bool): void {
        setTemperature(temperature + (warmer ? -step : step));
    }

    function toggle(): void {
        if (active)
            setTemperature(day);
        else
            setTemperature(lastOnTemperature < day ? lastOnTemperature : nightTemperature);
    }

    function useAutomatic(): void {
        manual = false;
        updateAuto();
        save();
    }

    function describe(t: int): string {
        if (t >= day) return qsTr("No filter");
        if (t >= 5000) return qsTr("Subtle");
        if (t >= 4000) return qsTr("Reading");
        if (t >= 3000) return qsTr("Warm");
        if (t >= 2300) return qsTr("Very warm");
        return qsTr("Candle");
    }

    function formatTime(d: date): string {
        return Qt.formatTime(d, "hh:mm");
    }

    // ------------------------------------------------------------------ sun maths

    // Returns [sunrise, sunset] for `when` as Date objects (NOAA general solar position).
    function sunTimes(when: date, lat: real, lon: real): var {
        const start = new Date(when.getFullYear(), 0, 1);
        const dayOfYear = Math.floor((when - start) / 86400000) + 1;
        const g = 2 * Math.PI / 365 * (dayOfYear - 1);
        const eqtime = 229.18 * (0.000075 + 0.001868 * Math.cos(g) - 0.032077 * Math.sin(g)
                       - 0.014615 * Math.cos(2 * g) - 0.040849 * Math.sin(2 * g));
        const decl = 0.006918 - 0.399912 * Math.cos(g) + 0.070257 * Math.sin(g)
                     - 0.006758 * Math.cos(2 * g) + 0.000907 * Math.sin(2 * g)
                     - 0.002697 * Math.cos(3 * g) + 0.00148 * Math.sin(3 * g);
        const latr = lat * Math.PI / 180;
        let cosHa = Math.cos(90.833 * Math.PI / 180) / (Math.cos(latr) * Math.cos(decl)) - Math.tan(latr) * Math.tan(decl);
        cosHa = Math.max(-1, Math.min(1, cosHa)); // polar day / night
        const ha = Math.acos(cosHa) * 180 / Math.PI;
        const midnightUtc = Date.UTC(when.getFullYear(), when.getMonth(), when.getDate());
        const rise = new Date(midnightUtc + (720 - 4 * (lon + ha) - eqtime) * 60000);
        const set = new Date(midnightUtc + (720 - 4 * (lon - ha) - eqtime) * 60000);
        return [rise, set];
    }

    function autoTemperatureAt(now: date): int {
        const times = sunTimes(now, latitude, longitude);
        sunrise = times[0];
        sunset = times[1];

        if (!followSun)
            return day;

        const half = transitionMinutes * 30000; // half the fade, in ms
        const night = nightTemperature;
        const blend = (centre, from, to) => {
            const t = half > 0 ? Math.max(0, Math.min(1, (now - (centre - half)) / (2 * half))) : (now >= centre ? 1 : 0);
            return Math.round(from + (to - from) * t);
        };

        if (now < times[0].getTime() + half)
            return blend(times[0].getTime(), night, day); // night and sunrise
        if (now < times[1].getTime() - half)
            return day; // daytime
        return blend(times[1].getTime(), day, night); // sunset and night
    }

    function updateAuto(): void {
        autoTemperature = autoTemperatureAt(new Date());
    }

    // ------------------------------------------------------------------ hyprsunset

    function apply(force: bool): void {
        if (!force && applied === temperature)
            return;
        applied = temperature;
        if (temperature >= day)
            Quickshell.execDetached(["hyprctl", "hyprsunset", "identity"]);
        else
            Quickshell.execDetached(["hyprctl", "hyprsunset", "temperature", String(temperature)]);
    }

    function save(): void {
        storage.setText(JSON.stringify({
            manual: manual,
            manualTemperature: manualTemperature,
            lastOnTemperature: lastOnTemperature
        }));
    }

    onTemperatureChanged: debounce.restart()
    onSettingsChanged: updateAuto()
    onFollowSunChanged: updateAuto()
    onNightTemperatureChanged: updateAuto()
    onTransitionMinutesChanged: updateAuto()
    onLatitudeChanged: updateAuto()
    onLongitudeChanged: updateAuto()

    // Coalesces slider drags into a few hyprctl calls
    Timer {
        id: debounce

        interval: 50
        onTriggered: root.apply(false)
    }

    // Recompute every 15 s so fades are smooth (changes are applied as they happen via
    // onTemperatureChanged). Force a re-apply once a minute to recover from hyprsunset
    // being restarted or something else touching the CTM.
    Timer {
        property int ticks: 0

        running: true
        repeat: true
        triggeredOnStart: true
        interval: 15000
        onTriggered: {
            root.updateAuto();
            if (ticks++ % 4 === 0)
                root.apply(true);
        }
    }

    // Start hyprsunset if nothing else (e.g. a systemd unit) already runs it
    Process {
        running: !root.hyprsunsetChecked
        command: ["pidof", "hyprsunset"]
        onExited: code => {
            root.hyprsunsetChecked = true;
            if (code !== 0) {
                Quickshell.execDetached(["hyprsunset", "--identity"]);
                reapplyAfterStart.start();
            }
        }
    }

    Timer {
        id: reapplyAfterStart

        interval: 1000
        onTriggered: root.apply(true)
    }

    FileView {
        id: storage

        printErrors: false
        path: `${Paths.state}/nightlight.json`
        onLoaded: {
            try {
                const data = JSON.parse(text());
                root.manual = data.manual ?? false;
                root.manualTemperature = data.manualTemperature ?? root.day;
                root.lastOnTemperature = data.lastOnTemperature ?? root.nightTemperature;
            } catch (e) {}
        }
    }

    IpcHandler {
        target: "nightLight"

        function toggle(): void { root.toggle(); }
        function automatic(): void { root.useAutomatic(); }
        function warmer(): void { root.nudge(true); }
        function cooler(): void { root.nudge(false); }
        function set(kelvin: int): void { root.setTemperature(kelvin); }
        function get(): int { return root.temperature; }
    }
}
