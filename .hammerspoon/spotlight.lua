--
--
-- Alternative for Apple Spotlight
--
local fu = require("fileutils")
local util = require("utils")
local reloadApplication = { text = "Reload applications", uuid = "reload" }
local finderApplication = {
    text = "Finder",
    uuid = "Finder",
    image = hs.image.imageFromAppBundle("com.apple.finder")
}
local intellijInfo = hs.application.infoForBundleID("com.jetbrains.intellij")
local intellijLibraryVersion=string.sub(intellijInfo.CFBundleShortVersionString,1,6)

local chooseApplication

function buildApplicationChoices(apps, directory)
    -- local applications = util:split(hs.execute("ls '" .. directory) .. "'", "\n")

    for application in io.popen("ls \"" .. directory .. "\""):lines() do
        if application:sub(-4,-1) == ".app" then
            table.insert(apps, {
                text = string.gsub(application, ".app", ""),
                uuid = application,
                image = hs.image.imageFromMediaFile(directory .. "/" .. application)
            })
        else
            buildApplicationChoices(apps, directory .. "/" .. application)
        end
    end
end

function initializeApplicationChoices()
    local applicationChoices = { finderApplication }

    buildApplicationChoices(applicationChoices, "/Applications")
    buildApplicationChoices(applicationChoices, "/System/Applications")
    findIntellijProjects(applicationChoices)
    util:reverse(applicationChoices)
    table.insert(applicationChoices, reloadApplication)

    return applicationChoices
end

function findIntellijProjects(apps)
    local path = hs.fs.pathToAbsolute("~/Library/Application Support/JetBrains/IntellijIdea" .. intellijLibraryVersion .. "/options/recentProjects.xml")
    if not path then
        return {}
    end
    local recentProjectsFile = fu:read_file(path)
    for match in recentProjectsFile:gmatch "entry key=\".-\"" do
        local path = match:sub(12,-2)
        if path:sub(1,11) == "$USER_HOME$" then
            -- Replace HOMEDIR with actual path
            path = os.getenv("HOME") .. path:sub(12)
        end
        local projectName = string.gsub(path, path:match(".*/"), "")
        table.insert(apps, {
            text = projectName,
            uuid = path,
            idea = true,
            image = hs.image.imageFromAppBundle("com.jetbrains.intellij")
        })
    end
end

function onCompletionHandler(result)
    if not result then
        return
    end
    if result.uuid == reloadApplication.uuid then
        chooseApplication:choices(initializeApplicationChoices())
    elseif result.idea then
        local exe = hs.application.pathForBundleID("com.jetbrains.intellij")
        io.popen("\"" .. exe .. "/Contents/MacOS/idea\" \"" .. result.uuid .. "\" &"):close()
    else
        hs.application.launchOrFocus(result.uuid)
    end
end

chooseApplication = hs.chooser.new(onCompletionHandler)
                      :placeholderText("Search apps")
                      :choices(initializeApplicationChoices())
                      :rows(10)

hs.hotkey.bind(cah, "space", util:bind(chooseApplication, "show"))
-- hs.hotkey.bind({ "cmd" }, "space", util:bind(chooseApplication, "show"))

