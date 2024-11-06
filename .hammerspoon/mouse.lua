-- Find my mouse pointer

firstDown = 0
ctrlWasDown = false

pingResponses = {
    didStart = {alpha=0.5, blue=1},
    didFail = {red=1},
    sendPacketFailed = {red=1},
    receivedPacket = {green=1}
}

tap = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(event)
    local flags = event:getFlags()
    local ctrlDown = flags["ctrl"]
    if ctrlDown then
        if not ctrlWasDown then
            ctrlWasDown = true

            local now = hs.timer.absoluteTime()
            if firstDown + 500000000 > now and mouseCircle == nil then
                local p = hs.mouse.absolutePosition()
                local mouseCircle = hs.canvas.new({x=p.x-200,y=p.y-200,w=400,h=400})
                local mouseCircleSize = 100
                mouseCircle:show()
                hs.network.ping.ping("8.8.8.8", 10, 0.1, 1, "any", function(_, message)
                    local pingColor=pingResponses[message]
                    if pingColor == nil then
                        mouseCircle:delete()
                    else
                        if mouseCircleSize > 0 then
                            mouseCircle:appendElements({action="stroke", type="circle", radius=tostring(mouseCircleSize/220), reversePath=true, strokeColor=pingColor, strokeWidth=15})
                            mouseCircleSize = mouseCircleSize - 10
                        end
                    end
                end)
            end
            firstDown = now
        end
    else
        ctrlWasDown = false
    end
    return false
end)
tap:start()
