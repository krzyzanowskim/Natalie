//
//  OS.swift
//  Natalie
//
//  Created by Marcin Krzyzanowski on 07/08/16.
//  Copyright © 2016 Marcin Krzyzanowski. All rights reserved.
//

import Foundation

enum OS: String, CustomStringConvertible {
    case iOS = "iOS"
    case OSX = "OSX"
    case tvOS = "tvOS"

    static let allValues = [iOS, OSX, tvOS]

    enum Runtime: String {
        case iOSCocoaTouch = "iOS.CocoaTouch"
        case MacOSXCocoa = "MacOSX.Cocoa"
        case AppleTV = "AppleTV"

        init(os: OS) {
            switch os {
            case iOS:
                self = .iOSCocoaTouch
            case OSX:
                self = .MacOSXCocoa
            case tvOS:
                self = .AppleTV
            }
        }
    }

    enum Framework: String {
        case UIKit = "UIKit"
        case Cocoa = "Cocoa"

        init(os: OS) {
            switch os {
            case iOS, .tvOS:
                self = .UIKit
            case OSX:
                self = .Cocoa
            }
        }
    }

    init(targetRuntime: String) {
        switch targetRuntime {
        case Runtime.iOSCocoaTouch.rawValue:
            self = .iOS
        case Runtime.MacOSXCocoa.rawValue:
            self = .OSX
        case Runtime.AppleTV.rawValue:
            self = .tvOS
        case "iOS.CocoaTouch.iPad":
            self = .iOS
        case "iOS.CocoaTouch.iPad":
            self = .iOS
        default:
            fatalError("Unsupported \(targetRuntime)")
        }
    }

    var description: String {
        return self.rawValue
    }

    var framework: String {
        return Framework(os: self).rawValue
    }

    var targetRuntime: String {
        return Runtime(os: self).rawValue
    }

    var storyboardType: String {
        switch self {
        case .iOS, .tvOS:
            return "UIStoryboard"
        case .OSX:
            return "NSStoryboard"
        }
    }

    var storyboardIdentifierType: String {
        switch self {
        case .iOS, .tvOS:
            return "String"
        case .OSX:
            return "NSStoryboard.Name"
        }
    }

    var storyboardSceneIdentifierType: String {
        switch self {
        case .iOS, .tvOS:
            return "String"
        case .OSX:
            return "NSStoryboard.SceneIdentifier"
        }
    }

    var storyboardSegueType: String {
        switch self {
        case .iOS, .tvOS:
            return "UIStoryboardSegue"
        case .OSX:
            return "NSStoryboardSegue"
        }
    }

    var storyboardSegueIdentifierType: String {
        switch self {
        case .iOS, .tvOS:
            return "String"
        case .OSX:
            return "NSStoryboardSegue.Identifier"
        }
    }

    var storyboardControllerTypes: [String] {
        switch self {
        case .iOS, .tvOS:
            return ["UIViewController"]
        case .OSX:
            return ["NSViewController", "NSWindowController"]
        }
    }

    var storyboardControllerReturnType: String {
        switch self {
        case .iOS, .tvOS:
            return "UIViewController"
        case .OSX:
            return "AnyObject" // NSViewController or NSWindowController
        }
    }

    var storyboardControllerSignatureType: String {
        switch self {
        case .iOS, .tvOS:
            return "ViewController"
        case .OSX:
            return "Controller" // NSViewController or NSWindowController
        }
    }

    var storyboardInstantiationInfo: [(String /* Signature type */, String /* Return type */)] {
        switch self {
        case .iOS, .tvOS:
            return [("ViewController", "UIViewController")]
        case .OSX:
            return [("Controller", "NSWindowController"), ("Controller", "NSViewController")]
        }
    }

    var viewType: String {
        switch self {
        case .iOS, .tvOS:
            return "UIView"
        case .OSX:
            return "NSView"
        }
    }

    var resuableViews: [String]? {
        switch self {
        case .iOS, .tvOS:
            return ["UICollectionReusableView", "UITableViewCell"]
        case .OSX:
            return nil
        }
    }

    func controllerType(for name: String) -> String? {
        switch self {
        case .iOS, .tvOS:
            switch name {
            case "viewController":
                return "UIViewController"
            case "navigationController":
                return "UINavigationController"
            case "tableViewController":
                return "UITableViewController"
            case "tabBarController":
                return "UITabBarController"
            case "splitViewController":
                return "UISplitViewController"
            case "pageViewController":
                return "UIPageViewController"
            case "collectionViewController":
                return "UICollectionViewController"
            case "exit", "viewControllerPlaceholder":
                return nil
            default:
                assertionFailure("Unknown controller element: \(name)")
                return nil
            }
        case .OSX:
            switch name {
            case "viewController":
                return "NSViewController"
            case "windowController":
                return "NSWindowController"
            case "pagecontroller":
                return "NSPageController"
            case "tabViewController":
                return "NSTabViewController"
            case "splitViewController":
                return "NSSplitViewController"
            case "exit", "viewControllerPlaceholder":
                return nil
            default:
                assertionFailure("Unknown controller element: \(name)")
                return nil
            }
        }
    }

}
