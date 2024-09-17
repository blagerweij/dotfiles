-- Binds Ctrl-Alt-Cmd + 'Z' to start your Zoom meeting instantly
-- example zoom.json file:
--
-- {
--     "meetings": [
--         { "text": "My Meeting", "id": "123456789", "pwd": "MySecretPwdGoesHere" },
--         { "text": "Another meeting", "id": "987654321", "pwd": "YourSecretPwdGoesThere" }
--     ],
--     "microsoft": {
--         "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx",
--         "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx",
--         "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
--         "redirectUri": "http://localhost:8910/login/oauth2/code/azure",
--         "port": 8910,
--         "duration": 300
--     }
-- }


sha256 = require("sha256")
utils = require("utils")

function openZoom(m)
    hs.urlevent.openURLWithBundle("zoommtg://zoom.us/join?confno=" .. m.id .. "&pwd=" .. m.pwd .. "&zc=0", "us.zoom.xos")
end

zoom = hs.json.read("zoom.json")

-- Start screen sharing (even when Zoom is not the focused app)
hs.hotkey.bind({"shift","cmd"}, "S", function()
    local app = hs.application.get("us.zoom.xos")
    if app ~= nil then
        app:selectMenuItem("Start share")
    end
end)

--
-- Binds Cmd-Ctrl-Cmd + 'A' to fetch the next zoom meeting from your Ourlook agenda
-- scan zoom meetings from Outlook, join if meeting scheduled for between now and 5 minutes
-- Note: requires a valid Client-ID in Azure-AD with a redirect-uri set to http://localhost:8910/login/oauth2/azure/code
--
_SCOPE = "offline_access https://graph.microsoft.com/Calendars.Read"
challenge = nil
settings = hs.settings.get("zoom")
if settings == nil then settings = { accessTokenExpiration= 0 } end

-- fetch Zoom meetings from outlook
function loadZoomMeetings()
    local now = math.floor(hs.timer.secondsSinceEpoch())
    local startDateTime = os.date("!%Y-%m-%dT%TZ",now) -- now or
    local endDateTime = os.date("!%Y-%m-%dT%TZ",now + zoom.microsoft.duration) -- next 5 minutes
    hs.http.asyncGet(
        "https://graph.microsoft.com/v1.0/me/calendar/calendarView?startDateTime=" .. startDateTime .. "&endDateTime=" .. endDateTime,
        {
            ["Authorization"] = "Bearer " .. settings.accessToken
        },
        function(status, body, headers)
            local result = hs.json.decode(body)
            local count = 0
            local z = {}
            for _, v in ipairs(result.value) do
                if v.location.uniqueId and v.location.uniqueId:find("zoom.us/j/") then -- TODO: support Microsoft Teams
                    _, _, label, meetingId, pwd = string.find(v.location.uniqueId, "https://(.*)zoom.us/j/(%d+)?pwd=(.*)")
                    table.insert(z, { id = meetingId, pwd = pwd, text = v.subject, image = hs.image.imageFromAppBundle("us.zoom.xos") })
                end
            end
            for _, v in ipairs(zoom.meetings) do
                table.insert(z,v)
            end
            hs.chooser.new(openZoom):placeholderText("Select meeting"):choices(z):show()
        end
    )
end

-- opens a new browser tab to the microsoftonline OAuth2 authorization page
function openAzureTab()
    challenge = utils:randomString(64)
    hs.urlevent.openURL("https://login.microsoftonline.com/" .. zoom.microsoft.tenant .. "/oauth2/v2.0/authorize?" .. utils:formencode({
        client_id = zoom.microsoft.clientId,
        response_type = "code",
        redirect_uri = zoom.microsoft.redirectUri,
        scope = _SCOPE,
        state = "12345",
        code_challenge = sha256:sha256_base64(challenge),
        code_challenge_method = 'S256'
    }))
end

-- callback for parsing HTTP response from token endpoint
function parseTokens(status,body,headers)
    if status ~= 200 then return end
    local response = hs.json.decode(body)
    settings.accessToken = response.access_token
    settings.refeshToken = response.refresh_token
    settings.accessTokenExpiration = math.floor(hs.timer.secondsSinceEpoch()) + response.expires_in
    hs.settings.set("zoom", settings) -- save refresh token across restarts of Hammerspoon
    loadZoomMeetings()
end

-- http server callback handler
function oauth2Callback(method,url,headers,body)
    local urlParts = hs.http.urlParts(url)
    if urlParts.path ~= "/login/oauth2/code/azure" then
        return "", 404, {}
    end
    local params = utils:formdecode(urlParts.query)
    hs.http.asyncPost(
        "https://login.microsoftonline.com/" .. zoom.microsoft.tenant .. "/oauth2/v2.0/token",
        utils:formencode({ 
            client_id = zoom.microsoft.clientId,
            scope = _SCOPE,
            code = params.code,
            redirect_uri = zoom.microsoft.redirectUri,
            grant_type = "authorization_code",
            code_verifier = challenge
        }),
        {
            ["Content-Type"] = "application/x-www-form-urlencoded"
        },
        parseTokens)
    return "Success, you may now close this tab", 200, { ["Content-Type"] = "text/html" }
end

hs.hotkey.bind({"cmd", "alt","ctrl"}, "Z", function()
    local now = math.floor(hs.timer.secondsSinceEpoch())
    if settings.accessTokenExpiration == nil or settings.accessTokenExpiration < now then
        if settings.refreshToken ~= nil then
            hs.http.asyncPost(
                "https://login.microsoftonline.com/" .. zoom.microsoft.tenant .. "/oauth2/v2.0/token",
                utils:formencode({ 
                    client_id = zoom.microsoft.clientId,
                    scope = _SCOPE,
                    redirect_uri = zoom.microsoft.redirectUri,
                    grant_type = "refresh_token",
                    refresh_token = settings.refreshToken
                }),
                {
                    ["Content-Type"] = "application/x-www-form-urlencoded"
                },
                parseTokens)
        else
            openAzureTab() -- refresh token is missing, get a new one
        end
    else
        loadZoomMeetings() -- we have a valid access token
    end
end)

server = hs.httpserver.new(false, false)
server:setPort(zoom.microsoft.port)
server:setCallback(oauth2Callback)
server:start()