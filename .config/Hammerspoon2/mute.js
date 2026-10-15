function broadcast(msg) {
    hs.ui.alert(msg).font(HSFont.system(100)).show()
}

// Send a keystroke straight to an app, even when it isn't focused
function keyStrokeTo(app, flags, key) {
    for (const down of [true, false]) {
        const e = hs.eventtap.makeKeyEvent(key, down)
        e.rawFlags = flags
        e.post(app)
    }
}

function toggleMicMute() {
    const mic = hs.audiodevice.defaultInputDevice()
    const zoom = hs.application.matchingBundleID("us.zoom.xos")
    const teams = hs.application.matchingBundleID("com.microsoft.teams2")
    const mute = !mic.inputMuted
    mic.inputMuted = mute

    const zoomItem = mute ? "Mute audio" : "Unmute audio"
    if (zoom?.findMenuItemByPath(["Meeting", zoomItem])) {
        zoom.selectMenuItemByPath(["Meeting", zoomItem])
    }
    // More than one Teams window means a call is in progress
    if (teams && teams.allWindows.length > 1) {
        const f = hs.eventtap.modifierFlags
        keyStrokeTo(teams, f.cmd | f.shift, "m")
    }
    broadcast(mute ? "📵 Muted" : "🎙 On air")
}

module.exports = [
    hs.hotkey.bind(["ctrl", "alt"], "space", toggleMicMute),
    hs.hotkey.bind([], "f20", toggleMicMute),
]
