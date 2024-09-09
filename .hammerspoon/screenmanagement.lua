--
-- Screen manipulation
--

-- Move screen to north
hs.hotkey.bind(cah, "Up", function()
    local win = hs.window.focusedWindow()
    if win:isFullScreen() then
        win:setFullScreen(false)
    end
    win:moveOneScreenNorth(false, true, 0)
end)
-- Move screen to south
hs.hotkey.bind(cah, "Down", function()
    local win = hs.window.focusedWindow()
    if win:isFullScreen() then
        win:setFullScreen(false)
    end
    win:moveOneScreenSouth(false, true, 0)
end)
