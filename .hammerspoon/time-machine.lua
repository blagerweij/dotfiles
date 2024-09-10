local rootDir = "~/dev"

-- exclude a folder from time-machine
function exclude(path) 
    if hs.fs.xattr.set(path, "com_apple_backup_excludeItem", "com.apple.backupd") then
        log.i("Excluded " .. path)
    end
end

-- list of folders to exclude
local exclude_dirs = {
    "~/Downloads",
    "~/go",
    "~/Library/Containers",
    "~/Library/Application Support",
    "~/.cache",
    "~/.docker",
    "~/.gradle",
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

-- exclude project output files
local keys={}
for key,_ in pairs(exclude_outputs) do
    table.insert(keys, key)
end
for f in hs.execute("find " .. rootDir .. " -type f \\( -name " .. table.concat(keys, " -o -name ") .. " \\)"):gmatch("[^\n]+") do
    local i = string.find(string.reverse(f), "/")
    local name = string.sub(f, string.len(f) - i + 2, -1)
    local dir = string.sub(f, 1, -i) .. exclude_outputs[name]
    if hs.fs.attributes(dir, "mode") == "directory" then
        exclude(dir)
    end
end

