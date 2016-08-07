//
//  natalie.swift
//  Natalie
//
//  Created by Marcin Krzyzanowski on 07/08/16.
//  Copyright © 2016 Marcin Krzyzanowski. All rights reserved.
//

import Foundation

//MARK: Objects
enum OS: String, CustomStringConvertible {
    case iOS = "iOS"
    case OSX = "OSX"

    static let allValues = [iOS, OSX]

    enum Runtime: String {
        case iOSCocoaTouch = "iOS.CocoaTouch"
        case MacOSXCocoa = "MacOSX.Cocoa"

        init(os: OS) {
            switch os {
            case iOS:
                self = .iOSCocoaTouch
            case OSX:
                self = .MacOSXCocoa
            }
        }
    }

    enum Framework: String {
        case UIKit = "UIKit"
        case Cocoa = "Cocoa"

        init(os: OS) {
            switch os {
            case iOS:
                self = .UIKit
            case OSX:
                self = .Cocoa
            }
        }
    }

    init(targetRuntime: String) {
        switch (targetRuntime) {
        case Runtime.iOSCocoaTouch.rawValue:
            self = .iOS
        case Runtime.MacOSXCocoa.rawValue:
            self = .OSX
        case "iOS.CocoaTouch.iPad":
            self = .iOS
        default:
            fatalError("Unsupported")
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
        case .iOS:
            return "UIStoryboard"
        case .OSX:
            return "NSStoryboard"
        }
    }

    var storyboardSegueType: String {
        switch self {
        case .iOS:
            return "UIStoryboardSegue"
        case .OSX:
            return "NSStoryboardSegue"
        }
    }

    var storyboardControllerTypes: [String] {
        switch self {
        case .iOS:
            return ["UIViewController"]
        case .OSX:
            return ["NSViewController", "NSWindowController"]
        }
    }

    var storyboardControllerReturnType: String {
        switch self {
        case .iOS:
            return "UIViewController"
        case .OSX:
            return "AnyObject" // NSViewController or NSWindowController
        }
    }

    var storyboardControllerSignatureType: String {
        switch self {
        case .iOS:
            return "ViewController"
        case .OSX:
            return "Controller" // NSViewController or NSWindowController
        }
    }

    var storyboardInstantiationInfo: [(String /* Signature type */, String /* Return type */)] {
        switch self {
        case .iOS:
            return [("ViewController", "UIViewController")]
        case .OSX:
            return [("Controller", "NSWindowController"), ("Controller", "NSViewController")]
        }
    }

    var viewType: String {
        switch self {
        case .iOS:
            return "UIView"
        case .OSX:
            return "NSView"
        }
    }

    var resuableViews: [String]? {
        switch self {
        case .iOS:
            return ["UICollectionReusableView", "UITableViewCell"]
        case .OSX:
            return nil
        }
    }

    func controllerTypeForElementName(name: String) -> String? {
        switch self {
        case .iOS:
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

class XMLObject {

    let xml: XMLIndexer
    let name: String

    init(xml: XMLIndexer) {
        self.xml = xml
        self.name = xml.element!.name
    }

    func searchAll(attributeKey: String, attributeValue: String? = nil) -> [XMLIndexer]? {
        return searchAll(root: self.xml, attributeKey: attributeKey, attributeValue: attributeValue)
    }

    func searchAll(root: XMLIndexer, attributeKey: String, attributeValue: String? = nil) -> [XMLIndexer]? {
        var result = Array<XMLIndexer>()
        for child in root.children {

            for childAtLevel in child.all {
                if let attributeValue = attributeValue {
                    if let element = childAtLevel.element, element.attributes[attributeKey] == attributeValue {
                        result += [childAtLevel]
                    }
                } else if let element = childAtLevel.element, element.attributes[attributeKey] != nil {
                    result += [childAtLevel]
                }

                if let found = searchAll(root: childAtLevel, attributeKey: attributeKey, attributeValue: attributeValue) {
                    result += found
                }
            }
        }
        return result.count > 0 ? result : nil
    }

    func searchNamed(name: String) -> [XMLIndexer]? {
        return self.searchNamed(root: self.xml, name: name)
    }

    func searchNamed(root: XMLIndexer, name: String) -> [XMLIndexer]? {
        var result = Array<XMLIndexer>()
        for child in root.children {

            for childAtLevel in child.all {
                if let elementName = childAtLevel.element?.name, elementName == name {
                    result += [child]
                }
                if let found = searchNamed(root: childAtLevel, name: name) {
                    result += found
                }
            }
        }
        return result.count > 0 ? result : nil
    }

    func searchById(id: String) -> XMLIndexer? {
        return searchAll(attributeKey: "id", attributeValue: id)?.first
    }
}

class Scene: XMLObject {

    lazy var viewController: ViewController? = {
        if let vcs = self.searchAll(attributeKey: "sceneMemberID", attributeValue: "viewController"), let vc = vcs.first {
            return ViewController(xml: vc)
        }
        return nil
    }()

    lazy var segues: [Segue]? = {
        return self.searchNamed(name: "segue")?.map { Segue(xml: $0) }
    }()

    lazy var customModule: String? = self.viewController?.customModule
    lazy var customModuleProvider: String? = self.viewController?.customModuleProvider
}

class ViewController: XMLObject {

    lazy var customClass: String? = self.xml.element?.attributes["customClass"]
    lazy var customModuleProvider: String? = self.xml.element?.attributes["customModuleProvider"]
    lazy var storyboardIdentifier: String? = self.xml.element?.attributes["storyboardIdentifier"]
    lazy var customModule: String? = self.xml.element?.attributes["customModule"]

    lazy var reusables: [Reusable]? = {
        if let reusables = self.searchAll(root: self.xml, attributeKey: "reuseIdentifier"){
            return reusables.map { Reusable(xml: $0) }
        }
        return nil
    }()
}

class Segue: XMLObject {
    let kind: String
    let identifier: String?
    lazy var destination: String? = self.xml.element?.attributes["destination"]

    override init(xml: XMLIndexer) {
        self.kind = xml.element!.attributes["kind"]!
        if let id = xml.element?.attributes["identifier"], id.characters.count > 0 {self.identifier = id}
        else                                                                            {self.identifier = nil}
        super.init(xml: xml)
    }

}

class Reusable: XMLObject {

    let kind: String
    lazy var reuseIdentifier: String? = self.xml.element?.attributes["reuseIdentifier"]
    lazy var customClass: String? = self.xml.element?.attributes["customClass"]


    override init(xml: XMLIndexer) {
        kind = xml.element!.name
        super.init(xml: xml)
    }
}

class Storyboard: XMLObject {

    let version: String
    lazy var os:OS = {
        guard let targetRuntime = self.xml["document"].element?.attributes["targetRuntime"] else {
            return OS.iOS
        }

        return OS(targetRuntime: targetRuntime)
    }()

    lazy var initialViewControllerClass: String? = {
        if let initialViewControllerId = self.xml["document"].element?.attributes["initialViewController"],
            let xmlVC = self.searchById(id: initialViewControllerId)
        {
            let vc = ViewController(xml: xmlVC)
            if let customClassName = vc.customClass {
                return customClassName
            }

            if let controllerType = self.os.controllerTypeForElementName(name: vc.name) {
                return controllerType
            }
        }
        return nil
    }()

    lazy var scenes: [Scene] = {
        guard let scenes = self.searchAll(root: self.xml, attributeKey: "sceneID") else {
            return []
        }

        return scenes.map { Scene(xml: $0) }
    }()

    lazy var customModules: [String] = self.scenes.filter{ $0.customModule != nil && $0.customModuleProvider == nil  }.map{ $0.customModule! }

    override init(xml: XMLIndexer) {
        self.version = xml["document"].element!.attributes["version"]!
        super.init(xml: xml)
    }

    func processStoryboard(storyboardName: String, os: OS) {
        print("")
        print("    struct \(storyboardName): Storyboard {")
        print("")
        print("        static let identifier = \"\(storyboardName)\"")
        print("")
        print("        static var storyboard: \(os.storyboardType) {")
        print("            return \(os.storyboardType)(name: self.identifier, bundle: nil)")
        print("        }")
        if let initialViewControllerClass = self.initialViewControllerClass {
            let cast = (initialViewControllerClass == os.storyboardControllerReturnType ? (os == OS.iOS ? "!" : "") : " as! \(initialViewControllerClass)")
            print("")
            print("        static func instantiateInitial\(os.storyboardControllerSignatureType)() -> \(initialViewControllerClass) {")
            print("            return self.storyboard.instantiateInitial\(os.storyboardControllerSignatureType)()\(cast)")
            print("        }")
        }
        for (signatureType, returnType) in os.storyboardInstantiationInfo {
            let cast = (returnType == os.storyboardControllerReturnType ? "" : " as! \(returnType)")
            print("")
            print("        static func instantiate\(signatureType)WithIdentifier(identifier: String) -> \(returnType) {")
            print("            return self.storyboard.instantiate\(signatureType)WithIdentifier(identifier)\(cast)")
            print("        }")

            print("")
            print("        static func instantiateViewController<T: \(returnType) where T: IdentifiableProtocol>(type: T.Type) -> T? {")
            print("            return self.storyboard.instantiateViewController(type)")
            print("        }")
        }
        for scene in self.scenes {
            if let viewController = scene.viewController, let storyboardIdentifier = viewController.storyboardIdentifier {
                let controllerClass = (viewController.customClass ?? os.controllerTypeForElementName(name: viewController.name)!)
                let cast = (controllerClass == os.storyboardControllerReturnType ? "" : " as! \(controllerClass)")
                print("")
                print("        static func instantiate\(SwiftRepresentationForString(string: storyboardIdentifier, capitalizeFirstLetter: true))() -> \(controllerClass) {")
                print("            return self.storyboard.instantiate\(os.storyboardControllerSignatureType)WithIdentifier(\"\(storyboardIdentifier)\")\(cast)")
                print("        }")
            }
        }
        print("    }")
    }

    func processViewControllers() {
        for scene in self.scenes {
            if let viewController = scene.viewController {
                if let customClass = viewController.customClass {
                    print("")
                    print("//MARK: - \(customClass)")

                    if let segues = scene.segues?.filter({ return $0.identifier != nil }), segues.count > 0 {
                        print("extension \(os.storyboardSegueType) {")
                        print("    func selection() -> \(customClass).Segue? {")
                        print("        if let identifier = self.identifier {")
                        print("            return \(customClass).Segue(rawValue: identifier)")
                        print("        }")
                        print("        return nil")
                        print("    }")
                        print("}")
                        print("")
                    }

                    if let storyboardIdentifier = viewController.storyboardIdentifier {
                        print("extension \(customClass): IdentifiableProtocol { ")
                        if viewController.customModule != nil {
                            print("    var storyboardIdentifier: String? { return \"\(storyboardIdentifier)\" }")
                        } else {
                            print("    public var storyboardIdentifier: String? { return \"\(storyboardIdentifier)\" }")
                        }
                        print("    static var storyboardIdentifier: String? { return \"\(storyboardIdentifier)\" }")
                        print("}")
                        print("")
                    }

                    if let segues = scene.segues?.filter({ return $0.identifier != nil }), segues.count > 0 {
                        print("extension \(customClass) { ")
                        print("")
                        print("    enum Segue: String, CustomStringConvertible, SegueProtocol {")
                        for segue in segues {
                            if let identifier = segue.identifier
                            {
                                print("        case \(SwiftRepresentationForString(string: identifier)) = \"\(identifier)\"")
                            }
                        }
                        print("")
                        print("        var kind: SegueKind? {")
                        print("            switch (self) {")
                        var needDefaultSegue = false
                        for segue in segues {
                            if let identifier = segue.identifier {
                                print("            case \(SwiftRepresentationForString(string: identifier)):")
                                print("                return SegueKind(rawValue: \"\(segue.kind)\")")
                            } else {
                                needDefaultSegue = true
                            }
                        }
                        if needDefaultSegue {
                            print("            default:")
                            print("                assertionFailure(\"Invalid value\")")
                            print("                return nil")
                        }
                        print("            }")
                        print("        }")
                        print("")
                        print("        var destination: \(self.os.storyboardControllerReturnType).Type? {")
                        print("            switch (self) {")
                        var needDefaultDestination = false
                        for segue in segues {
                            if let identifier = segue.identifier, let destination = segue.destination,
                                let destinationElement = searchById(id: destination)?.element,
                                let destinationClass = (destinationElement.attributes["customClass"] ?? os.controllerTypeForElementName(name: destinationElement.name))
                            {
                                print("            case \(SwiftRepresentationForString(string: identifier)):")
                                print("                return \(destinationClass).self")
                            } else {
                                needDefaultDestination = true
                            }
                        }
                        if needDefaultDestination {
                            print("            default:")
                            print("                assertionFailure(\"Unknown destination\")")
                            print("                return nil")
                        }
                        print("            }")
                        print("        }")
                        print("")
                        print("        var identifier: String? { return self.description } ")
                        print("        var description: String { return self.rawValue }")
                        print("    }")
                        print("")
                        print("}")
                    }

                    if let reusables = viewController.reusables?.filter({ return $0.reuseIdentifier != nil }), reusables.count > 0 {

                        print("extension \(customClass) { ")
                        print("")
                        print("    enum Reusable: String, CustomStringConvertible, ReusableViewProtocol {")
                        for reusable in reusables {
                            if let identifier = reusable.reuseIdentifier {
                                print("        case \(SwiftRepresentationForString(string: identifier, doNotShadow: reusable.customClass)) = \"\(identifier)\"")
                            }
                        }
                        print("")
                        print("        var kind: ReusableKind? {")
                        print("            switch (self) {")
                        var needDefault = false
                        for reusable in reusables {
                            if let identifier = reusable.reuseIdentifier {
                                print("            case \(SwiftRepresentationForString(string: identifier, doNotShadow: reusable.customClass)):")
                                print("                return ReusableKind(rawValue: \"\(reusable.kind)\")")
                            } else {
                                needDefault = true
                            }
                        }
                        if needDefault {
                            print("            default:")
                            print("                preconditionFailure(\"Invalid value\")")
                            print("                break")
                        }
                        print("            }")
                        print("        }")
                        print("")
                        print("        var viewType: \(self.os.viewType).Type? {")
                        print("            switch (self) {")
                        needDefault = false
                        for reusable in reusables {
                            if let identifier = reusable.reuseIdentifier, let customClass = reusable.customClass {
                                print("            case \(SwiftRepresentationForString(string: identifier, doNotShadow: reusable.customClass)):")
                                print("                return \(customClass).self")
                            } else {
                                needDefault = true
                            }
                        }
                        if needDefault {
                            print("            default:")
                            print("                return nil")
                        }
                        print("            }")
                        print("        }")
                        print("")
                        print("        var storyboardIdentifier: String? { return self.description } ")
                        print("        var description: String { return self.rawValue }")
                        print("    }")
                        print("")
                        print("}\n")
                    }
                }
            }
        }
    }
}

class StoryboardFile {
    let data: Data
    let storyboardName: String
    let storyboard: Storyboard

    init(filePath: String) throws {
        let url = URL(fileURLWithPath: filePath)
        self.data = try Data(contentsOf: url)
        self.storyboardName = ((filePath as NSString).lastPathComponent as NSString).deletingPathExtension
        self.storyboard = Storyboard(xml:SWXMLHash.parse(self.data))
    }
}


//MARK: Functions

func findStoryboards(rootPath: String, suffix: String) -> [String]? {
    var result = Array<String>()
    let fm = FileManager.default
    if let paths = fm.subpaths(atPath: rootPath) {
        let storyboardPaths = paths.filter({ return $0.hasSuffix(suffix)})
        // result = storyboardPaths
        for p in storyboardPaths {
            result.append((rootPath as NSString).appendingPathComponent(p))
        }
    }
    return result.count > 0 ? result : nil
}

func processStoryboards(storyboards: [StoryboardFile], os: OS) {

    print("//")
    print("// Autogenerated by Natalie - Storyboard Generator Script.")
    print("// http://blog.krzyzanowskim.com")
    print("//")
    print("")
    print("import \(os.framework)")
    let modules = storyboards.flatMap{ $0.storyboard.customModules }
    for module in Set<String>(modules) {
        print("import \(module)")
    }
    print("")

    print("//MARK: - Storyboards")

    print("")
    print("extension \(os.storyboardType) {")
    for (signatureType, returnType) in os.storyboardInstantiationInfo {
        print("    func instantiateViewController<T: \(returnType) where T: IdentifiableProtocol>(type: T.Type) -> T? {")
        print("        let instance = type.init()")
        print("        if let identifier = instance.storyboardIdentifier {")
        print("            return self.instantiate\(signatureType)WithIdentifier(identifier) as? T")
        print("        }")
        print("        return nil")
        print("    }")
        print("")
    }
    print("}")

    print("")
    print("protocol Storyboard {")
    print("    static var storyboard: \(os.storyboardType) { get }")
    print("    static var identifier: String { get }")
    print("}")
    print("")

    print("struct Storyboards {")
    for file in storyboards {
        file.storyboard.processStoryboard(storyboardName: file.storyboardName, os: os)
    }
    print("}")
    print("")

    print("//MARK: - ReusableKind")
    print("enum ReusableKind: String, CustomStringConvertible {")
    print("    case TableViewCell = \"tableViewCell\"")
    print("    case CollectionViewCell = \"collectionViewCell\"")
    print("")
    print("    var description: String { return self.rawValue }")
    print("}")
    print("")

    print("//MARK: - SegueKind")
    print("enum SegueKind: String, CustomStringConvertible {    ")
    print("    case Relationship = \"relationship\" ")
    print("    case Show = \"show\"                 ")
    print("    case Presentation = \"presentation\" ")
    print("    case Embed = \"embed\"               ")
    print("    case Unwind = \"unwind\"             ")
    print("    case Push = \"push\"                 ")
    print("    case Modal = \"modal\"               ")
    print("    case Popover = \"popover\"           ")
    print("    case Replace = \"replace\"           ")
    print("    case Custom = \"custom\"             ")
    print("")
    print("    var description: String { return self.rawValue } ")
    print("}")
    print("")
    print("//MARK: - IdentifiableProtocol")
    print("")
    print("public protocol IdentifiableProtocol: Equatable {")
    print("    var storyboardIdentifier: String? { get }")
    print("}")
    print("")
    print("//MARK: - SegueProtocol")
    print("")
    print("public protocol SegueProtocol {")
    print("    var identifier: String? { get }")
    print("}")
    print("")

    print("public func ==<T: SegueProtocol, U: SegueProtocol>(lhs: T, rhs: U) -> Bool {")
    print("    return lhs.identifier == rhs.identifier")
    print("}")
    print("")
    print("public func ~=<T: SegueProtocol, U: SegueProtocol>(lhs: T, rhs: U) -> Bool {")
    print("    return lhs.identifier == rhs.identifier")
    print("}")
    print("")
    print("public func ==<T: SegueProtocol>(lhs: T, rhs: String) -> Bool {")
    print("    return lhs.identifier == rhs")
    print("}")
    print("")
    print("public func ~=<T: SegueProtocol>(lhs: T, rhs: String) -> Bool {")
    print("    return lhs.identifier == rhs")
    print("}")
    print("")
    print("public func ==<T: SegueProtocol>(lhs: String, rhs: T) -> Bool {")
    print("    return lhs == rhs.identifier")
    print("}")
    print("")
    print("public func ~=<T: SegueProtocol>(lhs: String, rhs: T) -> Bool {")
    print("    return lhs == rhs.identifier")
    print("}")
    print("")

    print("//MARK: - ReusableViewProtocol")
    print("public protocol ReusableViewProtocol: IdentifiableProtocol {")
    print("    var viewType: \(os.viewType).Type? { get }")
    print("}")
    print("")

    print("public func ==<T: ReusableViewProtocol, U: ReusableViewProtocol>(lhs: T, rhs: U) -> Bool {")
    print("    return lhs.storyboardIdentifier == rhs.storyboardIdentifier")
    print("}")
    print("")

    print("//MARK: - Protocol Implementation")
    print("extension \(os.storyboardSegueType): SegueProtocol {")
    print("}")
    print("")

    if let reusableViews = os.resuableViews {
        for reusableView in reusableViews {
            print("extension \(reusableView): ReusableViewProtocol {")
            print("    public var viewType: UIView.Type? { return self.dynamicType }")
            print("    public var storyboardIdentifier: String? { return self.reuseIdentifier }")
            print("}")
            print("")
        }
    }

    for controllerType in os.storyboardControllerTypes {
        print("//MARK: - \(controllerType) extension")
        print("extension \(controllerType) {")
        print("    func performSegue<T: SegueProtocol>(segue: T, sender: AnyObject?) {")
        print("        if let identifier = segue.identifier {")
        print("            performSegueWithIdentifier(identifier, sender: sender)")
        print("        }")
        print("    }")
        print("")
        print("    func performSegue<T: SegueProtocol>(segue: T) {")
        print("        performSegue(segue, sender: nil)")
        print("    }")
        print("}")
        print("")
    }

    if os == OS.iOS {
        print("//MARK: - UICollectionView")
        print("")
        print("extension UICollectionView {")
        print("")
        print("    func dequeueReusableCell<T: ReusableViewProtocol>(reusable: T, forIndexPath: NSIndexPath!) -> UICollectionViewCell? {")
        print("        if let identifier = reusable.storyboardIdentifier {")
        print("            return dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: forIndexPath)")
        print("        }")
        print("        return nil")
        print("    }")
        print("")
        print("    func registerReusableCell<T: ReusableViewProtocol>(reusable: T) {")
        print("        if let type = reusable.viewType, identifier = reusable.storyboardIdentifier {")
        print("            registerClass(type, forCellWithReuseIdentifier: identifier)")
        print("        }")
        print("    }")
        print("")
        print("    func dequeueReusableSupplementaryViewOfKind<T: ReusableViewProtocol>(elementKind: String, withReusable reusable: T, forIndexPath: NSIndexPath!) -> UICollectionReusableView? {")
        print("        if let identifier = reusable.storyboardIdentifier {")
        print("            return dequeueReusableSupplementaryViewOfKind(elementKind, withReuseIdentifier: identifier, forIndexPath: forIndexPath)")
        print("        }")
        print("        return nil")
        print("    }")
        print("")
        print("    func registerReusable<T: ReusableViewProtocol>(reusable: T, forSupplementaryViewOfKind elementKind: String) {")
        print("        if let type = reusable.viewType, identifier = reusable.storyboardIdentifier {")
        print("            registerClass(type, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: identifier)")
        print("        }")
        print("    }")
        print("}")

        print("//MARK: - UITableView")
        print("")
        print("extension UITableView {")
        print("")
        print("    func dequeueReusableCell<T: ReusableViewProtocol>(reusable: T, forIndexPath: NSIndexPath!) -> UITableViewCell? {")
        print("        if let identifier = reusable.storyboardIdentifier {")
        print("            return dequeueReusableCellWithIdentifier(identifier, forIndexPath: forIndexPath)")
        print("        }")
        print("        return nil")
        print("    }")
        print("")
        print("    func registerReusableCell<T: ReusableViewProtocol>(reusable: T) {")
        print("        if let type = reusable.viewType, identifier = reusable.storyboardIdentifier {")
        print("            registerClass(type, forCellReuseIdentifier: identifier)")
        print("        }")
        print("    }")
        print("")
        print("    func dequeueReusableHeaderFooter<T: ReusableViewProtocol>(reusable: T) -> UITableViewHeaderFooterView? {")
        print("        if let identifier = reusable.storyboardIdentifier {")
        print("            return dequeueReusableHeaderFooterViewWithIdentifier(identifier)")
        print("        }")
        print("        return nil")
        print("    }")
        print("")
        print("    func registerReusableHeaderFooter<T: ReusableViewProtocol>(reusable: T) {")
        print("        if let type = reusable.viewType, identifier = reusable.storyboardIdentifier {")
        print("             registerClass(type, forHeaderFooterViewReuseIdentifier: identifier)")
        print("        }")
        print("    }")
        print("}")
        print("")
    }

    for file in storyboards {
        file.storyboard.processViewControllers()
    }

}
