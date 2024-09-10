-- Find my mouse pointer

local mouseCircle = nil
local mouseCircleTimer = nil

hs.hotkey.bind({"cmd","alt","ctrl"}, "D", function() 
    if mouseCircle then
        mouseCircle:delete()
        if mouseCircleTimer then
            mouseCircleTimer:stop()
        end
    end
    mousepoint = hs.mouse.getAbsolutePosition ()
    mouseCircle = hs.drawing.circle(hs.geometry.rect(mousepoint.x-40, mousepoint.y-40, 80, 80))
    mouseCircle:setStrokeColor({["red"]=1,["blue"]=0,["green"]=0,["alpha"]=1})
    mouseCircle:setFill(false)
    mouseCircle:setStrokeWidth(10)
    mouseCircle:show()

    -- Set a timer to delete the circle after 3 seconds
    mouseCircleTimer = hs.timer.doAfter(3, function() 
        mouseCircle:hide(0.5)
        mouseCircleTimer = nil
        hs.timer.doAfter(0.6, function()
            mouseCircle:delete()
            mouseCircle = nil
        end)
    end)
end)
