# Natalie
Natalie - Storyboard Code Generator (for Swift)

## Synopsis
Script generate Swift code based on storyboard files to make work with Storyboards and segues easier. Generated file **reduce usage of Strings** as identifiers for Segues or Storyboards.

This is a proof of concept to address the String issue for strongly typed Swift language. Natalie is a Swift script (written in Swift) that produces a single `.swift` file with a bunch of extensions to project classes along the generated Storyboard enum.

Since Natalie is a Swift script, that means it is written in Swift and requires Swift to run. The project uses [SWXMLHash](https://github.com/drmohundro/SWXMLHash) as a dependency to parse XML and due to framework limitations all code is in a single file.

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

###Reusable Views To Improve Performance

Collections and tables views use `reuseidentifier` on cell to recycle a view.

If you define it, their custom view controllers will be extended with an `Reusable` enumeration, which contains list of available reusable identifiers

example to dequeue a view with `Reusable` enumeration
```swift
class MyCustomTableViewController: UITableViewController, UITableViewDataSource {

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.dequeueReusableCell(Reusable.myCellId, forIndexPath: indexPath) as! UITableViewCell
    }
```

Before dequeuing your view, you must register a class or a xib for each identifier.
If your cell view has custom class definied in storyboard, in your controller you can call directly
```swift
override func viewDidLoad()  {
     self.registerReusableCell(Reusable.myCellId)
```
You can pass the view instead - the view must define the `reuseidentifier`
```swift
     self.registerReusableCell(theView) // view from IBOutlet or new instance
```

If your custom reusable view, you can also execute code according to reusable values
```swift
class MyCustomTableViewCell: UITableViewCell {
    override func prepareForReuse() {
        if self == MyCustomTableViewController.Reusable.myCellId {
            ...
        }
        else if self == MyCustomTableViewController.Reusable.mySecondCellId {
            ...
        }
```

##Installation

There is no need to do any installation, however if you want easy Xcode integration you may want to install the script to be easily accessible for any application from `/usr/local/bin`

```
$ git clone https://github.com/krzyzanowskim/Natalie.git
$ sudo cp natalie.swift /usr/local/bin/natalie.swift
```

###Xcode Integration

Natalie can be integrated with Xcode in such a way that the `Storyboards.swift` file will be updated with every build of the project, so you don't have to do it manually every time.

This is my setup created with **New Run Script Phase** on **Build Phase** Xcode target setting. It is important to move this phase above Compilation phase because this file is expected to be up to date for the rest of the application.

```
echo "Natalie generator"
/usr/local/bin/natalie.swift "$PROJECT_DIR/$PROJECT_NAME" > "$PROJECT_DIR/$PROJECT_NAME/Storyboards.swift"
```

Don't forget to add `Storyboards.swift` to the project.

##Usage:

Download Natalie from Github: https://github.com/krzyzanowskim/Natalie and use it in the console, for example like this:
```
$ git clone https://github.com/krzyzanowskim/Natalie.git
$ cd Natalie
```

The script expects one of two types of parameters:

* path to a single .storyboard file 
* path to a folder

If the parameter is a Storyboard file, then this file will be used. If a path to a folder is provided Natalie will generate code for every storyboard found inside.

```
$ natalie.swift NatalieExample/NatalieExample/Base.lproj/Main.storyboard > NatalieExample/NatalieExample/Storyboards.swift
```

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
 
