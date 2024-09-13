-- Binds Ctrl-Alt-Cmd + 'Z' to start your Zoom meeting instantly
-- example zoom.json file: { "Z": { "id": "123456789", "pwd": "xxxx" }, "S": { "id": "987654321", "pwd": "xxxx"} }

local mappings = hs.json.read("zoom.json")
if mappings ~= nil then
  for k,m in pairs(mappings) do
    hs.hotkey.bind({"cmd","alt","ctrl"}, k, function() 
        hs.urlevent.openURLWithBundle("zoommtg://zoom.us/join?confno=" .. m.id .. "&pwd=" .. m.pwd .. "&zc=0", "us.zoom.xos")
    end)
  end
end

-- Start screen sharing (even when Zoom is not the focused app)
hs.hotkey.bind({"shift","cmd"}, "S", function()
    local app = hs.application.get("us.zoom.xos")
    if app ~= nil then
        app:selectMenuItem("Start share")
    end
end)
