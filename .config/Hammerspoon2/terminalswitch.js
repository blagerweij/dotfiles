//
// Switch between terminal and a different application
//

// Various BundleId's for terminal applications
// "com.apple.Terminal"
// "io.alacritty"
// "com.googlecode.iterm2"
const terminalApp = "com.apple.Terminal"

let previousOpenedApp = null

// Toggle between the terminal and the previously focussed app
module.exports = hs.hotkey.bind(["alt"], "space", () => {
    const win = hs.window.focusedWindow()
    const focussedApp = win?.application?.bundleID
    if (focussedApp !== terminalApp) {
        if (focussedApp) previousOpenedApp = focussedApp
        hs.application.launchOrFocus(terminalApp)
    } else if (previousOpenedApp) {
        hs.application.launchOrFocus(previousOpenedApp)
    }
})
