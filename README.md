# Natalie
Natalie - Storyboard Code Generator (for Swift)

## Synopsis
Script generate Swift code based on storyboard files to make work with Storyboards and segues easier. Generated file **reduce usage of Strings** as identifiers for Segues or Storyboards.

###Enumerate Storyboards
Generated enum Storyboards with convenient interface (drop-in replacement for UIStoryboard).

```swift
enum Storyboards: String {
    case Main = "Main"
    case Second = "Second"
    ...
```

Instantiate ViewController for storyboard
```swift
let vc:MyViewController = Storyboards.Main.instantiateInitialViewController()
```

example usage for prepareForSegue()

```swift
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let selection = segue.selection() {
        switch (selection, segue.destinationViewController) {
        case (MainViewController.Segue.ScreenOneSegue, let oneViewController as ScreenOneViewController):
            oneViewController.view.backgroundColor = UIColor.yellowColor()
        default: break
        }
    }
}
```

###Segues

Perform segue
```swift
self.performSegue(MyCustomViewController.Segue.goToDetails, sender:nil)
```

Each custom view controller is extended with this code and provide list of available segues and additional informations from Storyboard.

`storyboardIdentifier` is unique identifier of view controller in Storyboard

`Segue` enumeration contains list of available segues

`kind` property represent types Segue

`destination` property return type of destinated view controller.

```swift
extension MyCustomViewController { 
    var storyboardIdentifier:String { return "oEB-rK-hJd" }

    enum Segue: String, Printable {
        case goToDetails = "goToDetails"
        case expandGroup = "composeMessage"

        var kind: SegueKind? {
            ...
        }

        var destination: UIViewController.Type? {
            ...
        }

        var identifier: String { return self.description } 
        var description: String { return self.rawValue }
    }
}
```

##Installation

There is no need to install anything.

Simply download `natalie.swift` file and use it.

It is possible to integrate Natalie with Xcode using this **Run Script**

```
echo "Natalie generator"
/usr/local/bin/natalie.swift "$PROJECT_DIR/$PROJECT_NAME" > "$PROJECT_DIR/$PROJECT_NAME/Storyboards.swift"
```
don't forget to add generated `Storyboards.swift` to the project.

##Usage:

Generate file for single storyboard
```
$ natalie.swift Main.storyboard > Storyboards.swift
```

Generate file for any storyboard file found at given path

```
$ natalie.swift path/toproject > Storyboards.swift
```
 
## Author
Marcin Krzyżanowski http://blog.krzyzanowskim.com

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
 
