// Find my mouse pointer: double-tap ctrl to draw ping rings around it
// (green = 8.8.8.8 answered, red = failure)

const pingResponses = {
    didStart: { alpha: 0.5, blue: 1 },
    didFail: { red: 1 },
    sendPacketFailed: { red: 1 },
    receivedPacket: { green: 1 },
}

let firstDown = 0
let secondDown = 0
let ctrlWasDown = false
let activePing = null // ping objects are weakly held; keep the running one alive

function showMouseCircle() {
    const p = hs.mouse.absolutePosition()
    // canvas windows use bottom-left origin, the mouse uses top-left
    const screenH = hs.screen.primary().fullFrame.h
    const canvas = hs.canvas.create({ x: p.x - 200, y: screenH - p.y - 200, w: 400, h: 400 })
    canvas.ignoreMouseEvents(true)
    canvas.show()
    let size = 100
    activePing = hs.network.ping("8.8.8.8", {
        count: 10, interval: 0.1, timeout: 1, family: "any",
        callback: (_, event) => {
            const color = pingResponses[event]
            if (!color) {
                canvas.destroy()
                activePing = null
            } else if (size > 0) {
                canvas.appendElements([{ action: "stroke", type: "circle", radius: size * 1.8, strokeColor: color, strokeWidth: 15 }])
                size -= 10
            }
        },
    })
}

const tap = hs.eventtap.addWatcher([hs.eventtap.eventTypes.flagsChanged], (event) => {
    if (!event.flags.includes("ctrl")) {
        ctrlWasDown = false
        return
    }
    if (ctrlWasDown) return
    ctrlWasDown = true

    const now = hs.timer.absoluteTime()
    if (secondDown + 1e9 > now && !activePing) {
        firstDown = secondDown = 0
        showMouseCircle()
    } else if (firstDown + 1e9 > now) {
        secondDown = now
    } else {
        secondDown = 0
        firstDown = now
    }
}, true).start()

module.exports = tap
