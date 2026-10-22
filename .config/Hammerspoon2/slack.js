//
// Ctrl+Alt+Cmd+K anywhere: focus Slack and press Cmd+K ("Go" -> "Switch to Channel")
//
const slackBundleID = "com.tinyspeck.slackmacgap"

module.exports = hs.hotkey.bind(cah, "k", () => {
    // Delay so the hotkey's own modifiers are released before the synthetic Cmd+K
    const sendKey = () => hs.timer.doAfter(0.2, () => hs.eventtap.keyStroke(["cmd"], "k"))
    if (hs.application.frontmost()?.bundleID === slackBundleID) {
        sendKey()
        return
    }
    hs.application.once("didActivate", sendKey)
    hs.application.launchOrFocus(slackBundleID)
})
