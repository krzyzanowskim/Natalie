# XNatalie
Plugin to generate code when a storyboard is saved explicitly (File > Save or ⌘S)

XNatalie use [natalie.swift](https://github.com/krzyzanowskim/Natalie) to generate the storyboard code
- Directory passed to natalie.swift is: project(workspace) file directory + project name
- The generated `Storyboards.swift` is generated to: project(workspace) file directory + project name

## Setup
Open project and compile it.

XNatalie.xcplugin will be copied to `~/Library/Application Support/Developer/Shared/Xcode/Plug-ins`

Restart Xcode

## Configuration
### Enable plugin

Go to menu Product > Natalie > Enable

### Change script path

Go to menu Product > Natalie > Edit launch path

The default value is `"/usr/local/bin/natalie.swift`

### TODO
- Allow to customize directory passed to script and output file directory
