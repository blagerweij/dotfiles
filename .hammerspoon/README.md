# .Hammerspoon

This is my .hammerspoon directory.

The following shortcuts are supported:

## Window management:
- `ctrl + ⌥ + ⌘ + Left`  - move window to the left half of the screen
- `ctrl + ⌥ + ⌘ + Right` - move window to the right half of the screen
- `ctrl + ⌥ + Enter` - toggle fullscreen mode
- `ctrl + ⌥ + ⌘  + E` - show window hints

## Screen management:
- `ctrl + ⌥ + ⌘ + Up`  - move window to the previous monitor
- `ctrl + ⌥ + ⌘ + Down`  - move window to the next monitor

## Terminal management
- `⌥ + space` - switch between terminal and focussed app

## Spotlight
- `ctrl + ⌥ + ⌘ + space` - Alternative for Spotlight, only looks up applications and idea projects

## Mouse
- `ctrl (2x)` - Show location of mouse

## Zoom
- `ctrl + ⌥ + ⌘ + Z` - Start Zoom meeting using Personal Meeting Room
- `ctrl + ⌥ + ⌘ + S` - Join Zoom meeting using Daily Standup Meeting Room
- `ctrl + ⌥ + ⌘ + A` - Scan Outlook for any Zoom meetings that are about to start. 

If more than one Zoom meeting is found in your calendar, then you can choose one in the chooser.


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
