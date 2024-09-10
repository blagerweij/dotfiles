# .Hammerspoon

This is my .hammerspoon directory.

The following shortcuts are supported:

## Window management:
- `ctrl + ⌥ + ⌘  + Left`  - move window to the left
- `ctrl + ⌥ + ⌘  + Right` - move window to the right
- `ctrl + ⌥ + ⌘  + M` - toggle fullscreen mode
- `ctrl + ⌥ + ⌘  + E` - show window hints

## Screen management:
- `ctrl + ⌥ + ⌘ + Up`  - move window to the previous monitor
- `ctrl + ⌥ + ⌘ + Down`  - move window to the next monitor

## Terminal management
- `⌥ + space` - switch between terminal and focussed app

## Spotlight
- `⌘  + space` - Alternative for Spotlight, only looks up applications and idea projects

## Mouse
- `shift + ctrl + ⌘  + D` - Show location of mouse

## Time Machine
Upon startup, the hammerspoon scripts will exclude some folders from Time Machine backup:
- Downloads
- Golang caches
- Docker images and volumes
- Gradle caches
- Maven caches
- NodeJS / NPM caches
- Sonarqube caches
- Visual Studio Code caches

In addition, the time-machine.lua script will exclude 'build' folders:
- Gradle
- Python
- NPM
- Maven
- Golang
- Terraform
