-- Find my mouse pointer

local mouseCircle = nil
local mouseCircleTimer = nil
local mouseCircleSize = 100

local drawCircle = function()
    local mousepoint = hs.mouse.getAbsolutePosition ()
    if mouseCircle ~= nil then
        mouseCircle:delete()
    end
    mouseCircle = hs.drawing.circle(hs.geometry.rect(mousepoint.x-mouseCircleSize, mousepoint.y-mouseCircleSize, mouseCircleSize*2, mouseCircleSize*2))
    mouseCircle:setStrokeColor({["red"]=1,["blue"]=0,["green"]=0,["alpha"]=1})
    mouseCircle:setFill(false)
    mouseCircle:setStrokeWidth(25)
    mouseCircle:show()
    mouseCircle:hide(1)
end

function mouseFinder() 
    if mouseCircleSize > 0 then
        drawCircle()
        mouseCircleSize = mouseCircleSize - 10
        mouseCircleTimer = hs.timer.doAfter(0.1, mouseFinder)
    else
        mouseCircleTimer = nil
        mouseCircle:delete()
        mouseCircle = nil
    end
end

hs.hotkey.bind({"cmd","alt","ctrl"}, "D", function() 
    if mouseCircle then
        mouseCircle:delete()
        if mouseCircleTimer then
            mouseCircleTimer:stop()
        end
    end
    mouseCircleSize = 100
    mouseFinder()
end)

