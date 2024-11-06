--
-- Check internet connection with a ping to 8.8.8.8
--

pingResponses = {
    didStart = {alpha=0.5, blue=1},
    didFail = {red=1},
    sendPacketFailed = {red=1},
    receivedPacket = {green=1}
}

hs.hotkey.bind({"cmd", "alt","ctrl"}, "P", function()
    local max = hs.window.focusedWindow():screen():frame()
    local pingCircle = hs.canvas.new({x=max.x,y=max.y,w=max.w,h=max.h})
    local pingCircleSize = max.h/4
    local step = pingCircleSize/10
    local strokeWidth = step*3+1
    print(pingCircleSize)
    pingCircle:show()
	hs.network.ping.ping("8.8.8.8", 10, 0.1, 1, "any", function(_, message)
        print(message)
        local pingColor=pingResponses[message]
        if pingColor == nil then
            pingCircle:delete()
        else
            if pingCircleSize > 0 then
                pingCircle:appendElements({action="stroke", type="circle", radius=tostring(pingCircleSize/max.h), reversePath=true, strokeColor=pingColor, strokeWidth=strokeWidth})
                pingCircleSize = pingCircleSize - step
            end
        end
	end)
end)
