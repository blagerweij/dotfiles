function broadcast(msg, color)
    for i,v in pairs(hs.screen.allScreens()) do
        hs.alert.show(msg, {
            strokeWidth  = 10,
            strokeColor = { white = 1, alpha = 1 },
            fillColor   = { white = 0, alpha = 0.75 },
            textColor = color,
            textFont  = ".AppleSystemUIFont",
            textSize  = 100,
            radius = 27,
            atScreenEdge = 0,
            fadeInDuration = 0.15,
            fadeOutDuration = 0.15,
            padding = nil,
        }, v)
    end
end

function toggleMicMute()
    local mic = hs.audiodevice.defaultInputDevice()
    local zoom = hs.application.get("us.zoom.xos")
    local teams = hs.application.get("com.microsoft.teams2")
    if mic:muted() then
        mic:setInputMuted(false)
        if zoom then
            if zoom:findMenuItem({ "Meeting", "Unmute audio" }) ~= nil then
                zoom:selectMenuItem("Unmute audio")
            end
        end
        if teams then
            local n = 0
            for _ in pairs(teams:allWindows()) do n = n + 1 end
            if n > 1 then
                hs.eventtap.keyStroke({"cmd","shift"}, "m", 0, teams)
            end
        end
        broadcast("🎙 On air", { green = 1, alpha = 1 })
    else
        mic:setInputMuted(true)
        if zoom then
            if zoom:findMenuItem({ "Meeting", "Mute audio" }) ~= nil then
                zoom:selectMenuItem("Mute audio")
            end
        end
        if teams then
            local n = 0
            for _ in pairs(teams:allWindows()) do n = n + 1 end
            if n > 1 then
                hs.eventtap.keyStroke({"cmd","shift"}, "m", 0, teams)
            end
        end
        broadcast("📵 Muted", { red = 1, alpha = 1 })
    end
end

hs.hotkey.bind({ "ctrl", "alt" }, "space", toggleMicMute)
hs.hotkey.bind({ }, "F20", toggleMicMute)
