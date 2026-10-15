//
// Key defs (readable from required files, since init.js runs at global scope)
//
const cah = ["cmd", "alt", "ctrl"]

//
// Imports. Each module exports the hotkeys/watchers it creates; keeping them
// in this array stops the garbage collector from tearing them down.
//
const keepAlive = [
    require("./windowmanagement"),
    require("./terminalswitch"),
    require("./screenmanagement"),
    require("./spotlight"),
    require("./mouse"),
    // require("./time-machine"),
    require("./zoom"),
    require("./mute"),
    require("./spotify"),
    require("./reminder"),
]


hs.ui.alert("Hammerspoon loaded").show()
