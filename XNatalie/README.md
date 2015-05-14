# XNatalie
Xcode plugin to generate code from storyboard

XNatalie use [natalie.swift](https://github.com/krzyzanowskim/Natalie) to generate the storyboard code
- Directory passed to natalie.swift is: project(workspace) file directory + project name
- The generated `Storyboards.swift` is generated to: project(workspace) file directory + project name

## Setup
Open project and compile it

XNatalie.xcplugin will be copied to `~/Library/Application Support/Developer/Shared/Xcode/Plug-ins`

Restart Xcode

## Configuration
### Enable auto generation when user save storyboard file (File > Save or ⌘S)

Go to menu `Product > Natalie > Enable generate when saving`

### Change script path

Go to menu `Product > Natalie > Edit launch path`

The default value is `/usr/local/bin/natalie.swift`

### TODO
- Allow to customize directory passed to script and output file directory
