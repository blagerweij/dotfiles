function addReminder() {
    const id = "com.apple.reminders"
    hs.application.launchOrFocus(id).then(() => {
        hs.application.matchingBundleID(id)?.selectMenuItemByName("New Reminder")
    })
}

module.exports = hs.hotkey.bind(cah, "r", addReminder)
