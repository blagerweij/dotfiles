//
// Window manipulation
//

// Resize the focused window to a fraction of its screen (unit rect: 0..1)
const gridset = (x, y, w, h) => () => {
    const win = hs.window.focusedWindow()
    if (win) win.frame = new HSRect(x, y, w, h).fromUnitRect(win.screen.frame)
}

module.exports = [
    // Entire screen
    hs.hotkey.bind(["cmd", "alt"], "up", gridset(0, 0, 1, 1)),
    // Left 1/2 of the screen
    hs.hotkey.bind(["cmd", "alt"], "left", gridset(0, 0, 0.5, 1)),
    // Right 1/2 of the screen
    hs.hotkey.bind(["cmd", "alt"], "right", gridset(0.5, 0, 0.5, 1)),
    // Toggle Fullscreen mode
    hs.hotkey.bind(cah, "m", () => hs.window.focusedWindow()?.toggleFullscreen()),
]
