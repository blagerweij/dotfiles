--
-- Fix for the bug with Split-Tunnel in AWS Client VPN
-- For some reason, the default route is still routed over the VPN
-- This fixes that.
--

hs.network.reachability.forAddress("172.16.1.1"):setCallback(function(self, flags)
    if next(hs.network.interfaceDetails("utun4")) == nil then
        hs.alert.show("vpn down")
    else
        hs.alert.show("vpn up")
        hs.timer.delayed.new(3, function()
            hs.execute("sudo /sbin/route delete default -interface utun4")
            hs.execute("sudo /sbin/route add default -interface en0")
        end):start()
    end
end):start()
