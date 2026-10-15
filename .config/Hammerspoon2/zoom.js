// Ctrl-Alt-Cmd + Z: pick a Zoom/Teams meeting from your Outlook agenda (starting now
// up to `microsoft.duration` seconds from now) plus the fixed meetings in zoom.json.
// Shift-Cmd + S: start screen sharing in Zoom, even when Zoom isn't focused.
//
// example zoom.json file (keep it next to this file, never commit it):
//
// {
//     "meetings": [
//         { "text": "My Meeting", "id": "123456789", "pwd": "MySecretPwdGoesHere" },
//         { "text": "Another meeting", "id": "987654321" }
//     ],
//     "microsoft": {
//         "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx",
//         "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx",
//         "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
//         "redirectUri": "http://localhost:8910/login/oauth2/code/azure",
//         "port": 8910,
//         "duration": 300
//     }
// }
//
// Note: requires an Azure-AD app registration with the redirect-uri above.

if (!hs.fs.exists(`${__dirname}/zoom.json`)) {
    console.warn("zoom.js: zoom.json not found, Zoom hotkeys disabled")
    module.exports = []
    return
}

const zoom = require("./zoom.json")
const SCOPE = "offline_access https://graph.microsoft.com/Calendars.Read"
const tokenUrl = `https://login.microsoftonline.com/${zoom.microsoft.tenant}/oauth2/v2.0/token`
const settings = hs.userdefaults.get("zoom") ?? { accessTokenExpiration: 0 }
let verifier = null

const formencode = (form) =>
    Object.entries(form).map(([k, v]) => `${encodeURIComponent(k)}=${encodeURIComponent(v)}`).join("&")

// PKCE: base64url(sha256(verifier)); hs.hashing.sha256 returns hex
function codeChallenge(s) {
    const bytes = hs.hashing.sha256(s).match(/../g).map(h => parseInt(h, 16))
    const abc = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
    let out = ""
    for (let i = 0; i < bytes.length; i += 3) {
        const n = (bytes[i] << 16) | ((bytes[i + 1] ?? 0) << 8) | (bytes[i + 2] ?? 0)
        out += abc[n >> 18 & 63] + abc[n >> 12 & 63]
        if (i + 1 < bytes.length) out += abc[n >> 6 & 63]
        if (i + 2 < bytes.length) out += abc[n & 63]
    }
    return out
}

function randomString(length) {
    const chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let s = ""
    while (s.length < length) s += chars[Math.floor(Math.random() * chars.length)]
    return s
}

function openZoom(m) {
    if (!m) return
    if (m.id) {
        const pwd = m.pwd ? `&pwd=${m.pwd}` : ""
        hs.urlevent.openURLWithBundle(`zoommtg://zoom.us/join?confno=${m.id}${pwd}&zc=0`, "us.zoom.xos")
    } else if (m.joinUrl) {
        hs.urlevent.openURL(m.joinUrl)
    } else if (m.teamsUrl) {
        hs.urlevent.openURLWithBundle(m.teamsUrl, "com.microsoft.teams2")
        hs.pasteboard.writeString(m.teamsUrl)
    }
}

const chooser = hs.chooser.create()
chooser.placeholder = "Select meeting"
chooser.onSelect = openZoom

// fetch meetings from Outlook
function loadZoomMeetings() {
    const now = Date.now()
    const start = new Date(now).toISOString()
    const end = new Date(now + zoom.microsoft.duration * 1000).toISOString()
    hs.http.get(
        `https://graph.microsoft.com/v1.0/me/calendar/calendarView?startDateTime=${start}&endDateTime=${end}`,
        { Authorization: `Bearer ${settings.accessToken}` }
    ).then(({ status, body }) => {
        if (status !== 200) {
            console.error(`zoom.js: calendar fetch failed (${status})`)
            return
        }
        const zoomIcon = HSImage.fromAppBundle("us.zoom.xos")
        const choices = []
        for (const v of JSON.parse(body).value) {
            // Graph returns UTC without a zone suffix, with 7 fractional digits
            const time = new Date(v.start.dateTime.slice(0, 19) + "Z").toTimeString().slice(0, 5)
            const text = `${v.subject} (${time})`
            const loc = v.location?.uniqueId ?? ""
            const j = loc.match(/https:\/\/.*zoom\.us\/j\/(\d+)(?:\?pwd=([^&#\s]+))?/)
            if (j) {
                choices.push({ id: j[1], pwd: j[2], text, image: zoomIcon })
            } else if (loc.includes("zoom.us/my/")) {
                choices.push({ joinUrl: loc, text, image: zoomIcon })
            } else if (v.onlineMeeting?.joinUrl) {
                choices.push({ teamsUrl: v.onlineMeeting.joinUrl, text, image: HSImage.fromAppBundle("com.microsoft.teams2") })
            }
        }
        chooser.setChoices([...choices, ...zoom.meetings]).show()
    })
}

// opens a new browser tab to the microsoftonline OAuth2 authorization page
function openAzureTab() {
    verifier = randomString(64)
    hs.urlevent.openURL(`https://login.microsoftonline.com/${zoom.microsoft.tenant}/oauth2/v2.0/authorize?` + formencode({
        client_id: zoom.microsoft.clientId,
        response_type: "code",
        response_mode: "form_post", // Hammerspoon 2 strips the query string from `path`, so read the code from the body
        redirect_uri: zoom.microsoft.redirectUri,
        scope: SCOPE,
        state: "12345",
        code_challenge: codeChallenge(verifier),
        code_challenge_method: "S256",
    }))
}

function requestTokens(params) {
    hs.http.post(tokenUrl, formencode({
        client_id: zoom.microsoft.clientId,
        client_secret: zoom.microsoft.clientSecret,
        scope: SCOPE,
        redirect_uri: zoom.microsoft.redirectUri,
        ...params,
    }), { "Content-Type": "application/x-www-form-urlencoded" }).then(({ status, body }) => {
        if (status !== 200) {
            console.error(`zoom.js: token request failed (${status})`)
            // refresh token expired/revoked: fall back to interactive login
            if (params.grant_type === "refresh_token") {
                delete settings.refreshToken
                openAzureTab()
            }
            return
        }
        const response = JSON.parse(body)
        settings.accessToken = response.access_token
        settings.refreshToken = response.refresh_token ?? settings.refreshToken
        settings.accessTokenExpiration = Math.floor(Date.now() / 1000) + response.expires_in
        hs.userdefaults.set("zoom", settings) // keep refresh token across restarts
        loadZoomMeetings()
    })
}

// local http server receiving the OAuth2 redirect
const server = hs.httpserver.create()
    .setPort(zoom.microsoft.port)
    .setInterface("localhost")
    .setCallback((method, path, headers, body) => {
        if (!path.startsWith("/login/oauth2/code/azure")) {
            return { status: 404, body: "", headers: {} }
        }
        const code = `&${body}`.match(/&code=([^&]*)/)
        if (!code) return { status: 400, body: "Missing code", headers: {} }
        requestTokens({
            grant_type: "authorization_code",
            code: decodeURIComponent(code[1].replace(/\+/g, " ")),
            code_verifier: verifier,
        })
        return { status: 200, body: "Success, you may now close this tab", headers: { "Content-Type": "text/html" } }
    })
    .start()

module.exports = [
    server,
    chooser,
    hs.hotkey.bind(["shift", "cmd"], "s", () => {
        hs.application.matchingBundleID("us.zoom.xos")?.selectMenuItemByName("Start share")
    }),
    hs.hotkey.bind(cah, "z", () => {
        const now = Math.floor(Date.now() / 1000)
        if (settings.accessTokenExpiration > now) {
            loadZoomMeetings() // we have a valid access token
        } else if (settings.refreshToken) {
            requestTokens({ grant_type: "refresh_token", refresh_token: settings.refreshToken })
        } else {
            openAzureTab() // refresh token is missing, get a new one
        }
    }),
]
