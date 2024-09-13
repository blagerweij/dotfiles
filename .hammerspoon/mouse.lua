-- Find my mouse pointer

local mouseCircle = nil
local mouseCircleTimer = nil
local mouseCircleSize = 100

function mouseFinder() 
    if mouseCircleSize > 0 then
        mouseCircle:appendElements({action="stroke", type="circle", radius=tostring(mouseCircleSize/220), reversePath=true, strokeColor={alpha=mouseCircleSize/100, red=1.0}, strokeWidth=10})
        mouseCircleSize = mouseCircleSize - 10
        mouseCircleTimer = hs.timer.doAfter(0.1, mouseFinder)
    else
        mouseCircleTimer = nil
        mouseCircle:delete()
        mouseCircle = nil
    end
end

local firstDown = 0
local ctrlWasDown = false

hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(event)
    local flags = event:getFlags()
    local ctrlDown = flags["ctrl"]
    if ctrlDown then
        if not ctrlWasDown then
            ctrlWasDown = true
            local now = hs.timer.absoluteTime()
            if firstDown + 500000000 > now and mouseCircle == nil then
                local p = hs.mouse.absolutePosition()
                mouseCircle = hs.canvas.new({x=p.x-200,y=p.y-200,w=400,h=400})
                mouseCircleSize = 100
                mouseFinder()
                mouseCircle:show()
            end
            firstDown = now
        end
    else
        ctrlWasDown = false
    end
    return false
end):start()
