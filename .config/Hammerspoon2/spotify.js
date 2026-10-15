module.exports = hs.hotkey.bind(cah, "p", () => {
    hs.osascript.applescript('tell application "Spotify" to playpause')
        .then(r => console.log(JSON.stringify(r)))
})
