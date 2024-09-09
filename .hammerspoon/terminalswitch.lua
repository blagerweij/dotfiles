--
-- Switch between terminal and a different application
--

-- Various BundleId's for terminal applications
-- "com.apple.Terminal"
-- "io.alacritty"
-- "com.googlecode.iterm2"
local terminalApp = "com.apple.Terminal"

local previousOpenedApp = ""

-- Toggle between the terminal and the previously focussed app

hs.hotkey.bind({ "alt" }, "space", function()
	if hs.window.focusedWindow() == nil then
		hs.application.launchOrFocusByBundleID(terminalApp)
	else
		local focussedApp = hs.window.focusedWindow():application():bundleID()
		if focussedApp ~= terminalApp then
			previousOpenedApp = focussedApp
			hs.application.launchOrFocusByBundleID(terminalApp)
		elseif previousOpenedApp then
			hs.application.launchOrFocusByBundleID(previousOpenedApp)
		end
	end
end)
