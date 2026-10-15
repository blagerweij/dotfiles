// Exclude caches and build output folders from Time Machine
const rootDir = "~/dev"

function exclude(path) {
    console.log(`Excluding ${path} from time machine`)
    hs.fs.xattrSet(path, "com.apple.metadata:com_apple_backup_excludeItem", "com.apple.backupd")
}

// list of folders to exclude
const excludeDirs = [
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
    "~/.vscode",
]

// 'output' folders, the key is used to identity the type of project
const excludeOutputs = {
    "build.gradle": "build", // Gradle
    "build.gradle.kts": "build", // Gradle
    "requirements.txt": "venv", // Python
    "package.json": "node_modules", // NPM / YARN
    "pom.xml": "target", // Maven
    "go.mod": "vendor", // Golang
    "terraform.lock.hcl": ".terraform", // Terraform
}

excludeDirs.forEach(exclude)

// recursively travel the dev folder; stop descending once a project root is found
function traverse(path) {
    const subdirs = []
    for (const name of hs.fs.list(path) ?? []) {
        const full = `${path}/${name}`
        if (hs.fs.isSymlink(full)) continue
        if (hs.fs.isFile(full)) {
            const output = excludeOutputs[name]
            if (output !== undefined) {
                if (hs.fs.isDirectory(`${path}/${output}`)) exclude(`${path}/${output}`)
                return
            }
        } else if (hs.fs.isDirectory(full)) {
            subdirs.push(full)
        }
    }
    subdirs.forEach(traverse)
}

traverse(hs.fs.pathToAbsolute(rootDir))

module.exports = []
