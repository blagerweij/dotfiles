local rootDir = "~/dev"

-- exclude a folder from time-machine
function exclude(path) 
    print("Excluding " .. path .. " from time machine")
    hs.fs.xattr.set(path, "com.apple.metadata:com_apple_backup_excludeItem", "com.apple.backupd")
end

-- list of folders to exclude
local exclude_dirs = {
    "~/Downloads",
    "~/go",
    "~/Library/Containers",
    "~/Library/Group Containers",
    "~/Library/Application Support",
    "~/Library/Developer",
    "~/Library/Arduino15",
    "~/.cache",
    "~/.docker",
    "~/.gradle",
    "~/.ollama",
    "~/.m2",
    "~/.npm",
    "~/.nvm",
    "~/.sonar",
    "~/.vscode"
}

-- table of 'output' folders, the key is used to identity the type of project
local exclude_outputs = {
    ["build.gradle"]= "build", -- Gradle
    ["build.gradle.kts"]= "build", -- Gradle
    ["requirements.txt"]= "venv", -- Python
    ["package.json"]= "node_modules", -- NPM / YARN
    ["pom.xml"]= "target", -- Maven
    ["go.mod"]= "vendor", -- Golang
    ["terraform.lock.hcl"]= ".terraform" -- Terraform
}

-- exclude temp/cache folders
for _,d in ipairs(exclude_dirs) do
    exclude(d)
end

-- recursively travel the dev folder
function traverse(path)
    local subdirs = {}
    for name in hs.fs.dir(path) do
        local mode = hs.fs.symlinkAttributes(path .. "/" .. name, "mode")
        if mode == "file" then
            local output = exclude_outputs[name]
            if output ~= nil then
                local buildDir = path .. "/" .. output
                if hs.fs.symlinkAttributes(buildDir, "mode") == "directory" then
                    exclude(buildDir)
                end
                return
            end
        elseif mode == "directory" and name ~= "." and name ~= ".." then
            table.insert(subdirs, name)
        end
    end
    for _, name in pairs(subdirs) do
        traverse(path .. "/" .. name)
    end
end

-- run every day
-- hs.timer.doEvery(60*60*24, function()
    traverse(rootDir)
-- end)

