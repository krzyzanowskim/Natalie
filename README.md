# Natalie
Natalie - Storyboard Code Generator (for Swift)

## Swift

Current codebase is Swift 4 compatible.

Swift 3.x code may be found from [swift3](https://github.com/krzyzanowskim/Natalie/tree/swift3) branch

Swift 2.x code may be found from [swift2](https://github.com/krzyzanowskim/Natalie/tree/swift2) branch

## Synopsis
Natalie generates Swift code based on storyboard files to make work with Storyboards and segues easier. Generated file **reduce usage of Strings** as identifiers for Segues or Storyboards.

Proof of concept implementation to address the String issue for strongly typed Swift language. Natalie is a Swift command-line application (written in Swift) that produces a single `.swift` file with a bunch of extensions to project classes along the generated Storyboard enum.

Natalie is written in Swift and requires Swift to run. The project uses [SWXMLHash](https://github.com/drmohundro/SWXMLHash) as a dependency to parse XML and due to framework limitations.

### Enumerate Storyboards
Generated enum Storyboards with a convenient interface (drop-in replacement for UIStoryboard).

```swift
struct Storyboards {
    struct Main {...}
    struct Second {...}
    ...
```

Instantiate initial view controller for storyboard
```swift
let vc = Storyboards.Main.instantiateInitialViewController()
```

Instantiate ScreenTwoViewController in storyboard, using storyboard id
```swift
let vc = Storyboards.Main.instantiateScreenTwoViewController()
```

example usage for prepareForSegue()

```swift
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  if segue == MainViewController.Segue.ScreenOneSegue {    
    let viewController = segue.destinationViewController as? MyViewController
    viewController?.view.backgroundColor = UIColor.yellowColor()
  }
}
```

...it could be `switch { }` statement, but [it's broken](https://twitter.com/krzyzanowskim/status/611686899732869121).

### Segues

Perform segue
```swift
self.performSegue(MainViewController.Segue.ScreenOneSegue, sender:nil)
```

Each custom view controller is extended with this code and provide a list of available segues and additional information from Storyboard.

`Segue` enumeration contains list of available segues

`kind` property represent types Segue

`destination` property return type of destination view controller.

```swift
extension MainViewController {

    enum Segue: String, Printable, SegueProtocol {
        case ScreenOneSegueButton = "Screen One Segue Button"
        case ScreenOneSegue = "ScreenOneSegue"

        var kind: SegueKind? {
            ...
        }

        var destination: UIViewController.Type? {
            switch (self) {
            case ScreenOneSegueButton:
                return ScreenOneViewController.self
            case ScreenOneSegue:
                return ScreenOneViewController.self
            default:
                assertionFailure("Unknown destination")
                return nil
            }
        }

        var identifier: String { return self.description }
        var description: String { return self.rawValue }
    }
}
```

### Reusable Views To Improve Performance

Collections and tables views use `reuseidentifier` on cell to recycle a view.

If you define it, their custom view controllers will be extended with a `Reusable` enumeration, which contains list of available reusable identifiers

example to dequeue a view with `Reusable` enumeration with `UITableView`:
```swift
func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(ScreenTwoViewController.Reusable.MyCell, forIndexPath: indexPath) as! UITableViewCell
    cell.textLabel?.text = "\(indexPath.row)"
    return cell
}
```

Before dequeuing your view, you must register a class or a xib for each identifier.
If your cell view has custom class defined in storyboard, in your controller you can call directly
```swift
override func viewDidLoad()  {
    tableView.registerReusableCell(MainViewController.Reusable.MyCell)
}
```
You can pass the view instead - the view must define the `reuseidentifier`
```swift
    tableView.registerReusableCell(tableViewCell)
```

If your reusable custom view, you can also execute code according to reusable values
```swift
class MyCustomTableViewCell: UITableViewCell {
    override func prepareForReuse() {
        if self == MyCustomTableViewController.Reusable.MyCell {
            ...
        }
        else if self == MyCustomTableViewController.Reusable.mySecondCellId {
            ...
        }
    }
}
```

## Installation

#### Swift Package Manager

```
$ git clone https://github.com/krzyzanowskim/Natalie.git
$ cd Natalie
$ swift build -c release -Xswiftc -static-stdlib
$ cp .build/release/natalie ./natalie
```

if you want easy Xcode integration you may want to install the binary to be easily accessible for any application from `/usr/local/bin`

```
$ cp .build/release/natalie /usr/local/bin
```

#### Homebrew

```
$ brew install natalie
```

You can also put `natalie` executable file at the root of your project folder and keep it under version control. This way everyone even your CI will be able to generate the files.


### Xcode Integration

Natalie can be integrated with Xcode in such a way that the `Storyboards.swift` the file will be updated with every build of the project, so you don't have to do it manually every time.

This is my setup created with **New Run Script Phase** on **Build Phase** Xcode target setting. It is important to move this phase above Compilation phase because this file is expected to be up to date for the rest of the application.

- Select the project in the Project Navigator on the left of your Xcode window
- Select your App Target in the list
- Go in the "Build Phases" tab
- Click on the "+" button on the upper left corner and choose "New Run Script Phase" and copy/paste script:

```sh
echo "Natalie Generator: Determining if generated Swift file is up-to-date."

# Adjust path to "natalie" binary
# NATALIE_PATH="$PROJECT_DIR/natalie"
NATALIE_PATH="/usr/local/bin/natalie"

if [ -f $NATALIE_PATH ]; then
    BASE_PATH="$PROJECT_DIR/$PROJECT_NAME"
    OUTPUT_PATH="$BASE_PATH/Storyboards.swift"

    if [ ! -e "$OUTPUT_PATH" ] || [ -n "$(find "$BASE_PATH" -type f -name "*.storyboard" -newer "$OUTPUT_PATH" -print -quit)" ]; then
        echo "Natalie Generator: Generated Swift is out-of-date; re-generating..."

        /usr/bin/chflags nouchg "$OUTPUT_PATH"
        "$NATALIE_PATH" "$BASE_PATH" > "$OUTPUT_PATH"
        /usr/bin/chflags uchg "$OUTPUT_PATH"

        echo "Natalie Generator: Done."
    else
        echo "Natalie Generator: Generated Swift is up-to-date; skipping re-generation."
    fi
fi
```

- add `Storyboards.swift` to the project.

## Usage:

Download Natalie from Github: https://github.com/krzyzanowskim/Natalie and use it in the console, for example like this:
```
$ git clone https://github.com/krzyzanowskim/Natalie.git
$ cd Natalie
```

The command expects one of two types of parameters:

* path to a single .storyboard file
* path to a folder

If the parameter is a Storyboard file, then this file will be used. If a path to a folder is provided Natalie will generate code for every storyboard found inside.

```
$ natalie NatalieExample/NatalieExample/Base.lproj/Main.storyboard > NatalieExample/NatalieExample/Storyboards.swift
```

## Contribution

Please submit Pull Request against current development branch.

## Author and contact
Marcin Krzyżanowski

* [@krzyzanowskim](http://twitter.com/krzyzanowskim)
* http://blog.krzyzanowskim.com

## Licence
The MIT License (MIT)

Copyright (c) 2015 Marcin Krzyzanowski

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
