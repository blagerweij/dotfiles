--
-- Screen manipulation
--

-- Move to next screen
hs.hotkey.bind(cah, "Up", function()
    local win = hs.window.focusedWindow()
    if win:isFullScreen() then
        win:setFullScreen(false)
    end
    win:moveToScreen(win:screen():next())
end)
-- Move to previous screen
hs.hotkey.bind(cah, "Down", function()
    local win = hs.window.focusedWindow()
    if win:isFullScreen() then
        win:setFullScreen(false)
    end
    win:moveToScreen(win:screen():previous())
end)
