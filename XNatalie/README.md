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

## Troubleshooting
"I updated Xcode and now the plugin doesn't show up"

Xcode works on a UUID whitelist system, meaning each new version of Xcode needs to have its UUID added to plugin Info.plist file. If plugin isn't updated in time, you can do this update yourself (and by all means send a pull request afterwards!).

Get the UUID by running the following in the terminal:
`defaults read /Applications/Xcode.app/Contents/Info DVTPlugInCompatibilityUUID`

Then, open the plugin project and edit the *Supporting Files > Info.plist* file. You'll need to add the UUID you just copied to the `DVTPlugInCompatibilityUUIDs` section.

Rebuild the plugin, restart Xcode and you should see the menu reappear.

### TODO
- Allow to customize directory passed to script and output file directory
- Compatibility with xcode package manager Alcatraz?
