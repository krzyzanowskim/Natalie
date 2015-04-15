# Natalie
Natalie - Storyboard Code Generator Script (for Swift)

## Synopsis
Script generate Swift code based on storyboard files to make work with Storyboards and segues easier. Generated file **reduce usage of Strings** as identifiers for Segues or Storyboards.

###Enumerate Storyboards
Generated enum Storyboards with convenient interface (drop-in replacement for UIStoryboard).

```swift
enum Storyboards: String {
    case Main = "Main"

    private var instance:UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: nil)
    }

    func instantiateInitialViewController() -> UIViewController {
        switch (self) {
        case Main:
            return self.instance.instantiateInitialViewController() as UINavigationController
        default:
            return self.instance.instantiateInitialViewController() as UIViewController
        }
    }

    func instantiateViewControllerWithIdentifier(identifier: String) -> UIViewController {
        return self.instance.instantiateViewControllerWithIdentifier(identifier) as UIViewController
    }
}
```

Instantiate ViewController for storyboard
```swift
let vc:MyViewController = Storyboards.Main.instantiateInitialViewController()
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
            switch (self) {
            case goToDetails:
                return SegueKind(rawValue: "presentation")
            case composeMessage:
                return SegueKind(rawValue: "show")
            default:
                preconditionFailure("Invalid value")
                break
            }
        }

        var destination: UIViewController.Type? {
            switch (self) {
            case goToDetails:
                return DetailsViewController.self
            case expandGroup:
                return GroupViewController.self
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

##Installation

There is no need but if you want regenerate dependencies, you'll need [Rome](https://github.com/neonichu/Rome) plugin for CocoaPods

```
$ gem install cocoapods-rome
$ pod install --no-integrate --no-repo-update
```

##Usage:

Generate file for single storyboard
```
$ natalie.swift Main.storyboard > Storyboards.swift
```

Generate file for any storyboard file found at given path

```
$ natalie.swift path/toproject/with/storyboards > Storyboards.swift
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
 
