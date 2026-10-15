//
// Screen manipulation
//

// Move the focused window to another screen, keeping its relative position/size
const moveTo = (pick) => () => {
    const win = hs.window.focusedWindow()
    if (!win) return
    if (win.isFullscreen) win.toggleFullscreen()
    const from = win.screen
    win.frame = win.frame.toUnitRect(from.frame).fromUnitRect(pick(from).frame)
}

module.exports = [
    // Move to next screen
    hs.hotkey.bind(cah, "up", moveTo(s => s.next())),
    // Move to previous screen
    hs.hotkey.bind(cah, "down", moveTo(s => s.previous())),
]
