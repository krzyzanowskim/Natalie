#!/usr/bin/env xcrun -sdk macosx swift

//
// Natalie - Storyboard Generator Script
//
// Generate swift file based on storyboard files
//
// Usage:
// natalie.swift Main.storyboard > Storyboards.swift
// natalie.swift path/toproject/with/storyboards > Storyboards.swift
//
// Licence: MIT
// Author: Marcin Krzyżanowski http://blog.krzyzanowskim.com
//

//MARK: SWXMLHash
//
//  SWXMLHash.swift
//
//  Copyright (c) 2014 David Mohundro
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

//MARK: Extensions

public extension String {
  var trimAllWhitespacesAndSpecialCharacters: String {
    let invalidCharacters = NSCharacterSet.alphanumericCharacterSet().invertedSet
    let x = self.componentsSeparatedByCharactersInSet(invalidCharacters)
    return "".join(x)
  }
}

//MARK: Parser

let rootElementName = "SWXMLHash_Root_Element"

/// Simple XML parser.
public class SWXMLHash {
    /**
    Method to parse XML passed in as a string.

    :param: xml The XML to be parsed

    :returns: An XMLIndexer instance that is used to look up elements in the XML
    */
    class public func parse(xml: String) -> XMLIndexer {
        return parse((xml as NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
    }

    /**
    Method to parse XML passed in as an NSData instance.

    :param: xml The XML to be parsed

    :returns: An XMLIndexer instance that is used to look up elements in the XML
    */
    class public func parse(data: NSData) -> XMLIndexer {
        var parser = XMLParser()
        return parser.parse(data)
    }

    class public func lazy(xml: String) -> XMLIndexer {
        return lazy((xml as NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
    }

    class public func lazy(data: NSData) -> XMLIndexer {
        var parser = LazyXMLParser()
        return parser.parse(data)
    }
}

struct Stack<T> {
    var items = [T]()
    mutating func push(item: T) {
        items.append(item)
    }
    mutating func pop() -> T {
        return items.removeLast()
    }
    mutating func removeAll() {
        items.removeAll(keepCapacity: false)
    }
    func top() -> T {
        return items[items.count - 1]
    }
}

class LazyXMLParser : NSObject, NSXMLParserDelegate {
    override init() {
        super.init()
    }

    var root = XMLElement(name: rootElementName)
    var parentStack = Stack<XMLElement>()
    var elementStack = Stack<String>()

    var data: NSData?
    var ops: [IndexOp] = []

    func parse(data: NSData) -> XMLIndexer {
        self.data = data
        return XMLIndexer(self)
    }

    func startParsing(ops: [IndexOp]) {
        // clear any prior runs of parse... expected that this won't be necessary, but you never know
        parentStack.removeAll()
        root = XMLElement(name: rootElementName)
        parentStack.push(root)

        self.ops = ops
        let parser = NSXMLParser(data: data!)
        parser.delegate = self
        parser.parse()
    }

    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {

        elementStack.push(elementName)

        if !onMatch() {
            return
        }
        let currentNode = parentStack.top().addElement(elementName, withAttributes: attributeDict)
        parentStack.push(currentNode)
    }

    func parser(parser: NSXMLParser, foundCharacters string: String?) {
        if !onMatch() {
            return
        }

        let current = parentStack.top()
        if current.text == nil {
            current.text = ""
        }

        parentStack.top().text! += string!
    }

    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let match = onMatch()

        elementStack.pop()

        if match {
            parentStack.pop()
        }
    }

    func onMatch() -> Bool {
        // we typically want to compare against the elementStack to see if it matches ops, *but*
        // if we're on the first element, we'll instead compare the other direction.
        if elementStack.items.count > ops.count {
            return startsWith(elementStack.items, ops.map { $0.key })
        }
        else {
            return startsWith(ops.map { $0.key }, elementStack.items)
        }
    }
}

/// The implementation of NSXMLParserDelegate and where the parsing actually happens.
class XMLParser : NSObject, NSXMLParserDelegate {
    override init() {
        super.init()
    }

    var root = XMLElement(name: rootElementName)
    var parentStack = Stack<XMLElement>()

    func parse(data: NSData) -> XMLIndexer {
        // clear any prior runs of parse... expected that this won't be necessary, but you never know
        parentStack.removeAll()

        parentStack.push(root)

        let parser = NSXMLParser(data: data)
        parser.delegate = self
        parser.parse()

        return XMLIndexer(root)
    }

    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {

        let currentNode = parentStack.top().addElement(elementName, withAttributes: attributeDict)
        parentStack.push(currentNode)
    }

    func parser(parser: NSXMLParser, foundCharacters string: String?) {
        let current = parentStack.top()
        if current.text == nil {
            current.text = ""
        }

        parentStack.top().text! += string!
    }

    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        parentStack.pop()
    }
}

public class IndexOp {
    var index: Int
    let key: String

    init(_ key: String) {
        self.key = key
        self.index = -1
    }

    func toString() -> String {
        if index >= 0 {
            return key + " " + index.description
        }

        return key
    }
}

public class IndexOps {
    var ops: [IndexOp] = []

    let parser: LazyXMLParser

    init(parser: LazyXMLParser) {
        self.parser = parser
    }

    func findElements() -> XMLIndexer {
        parser.startParsing(ops)
        let indexer = XMLIndexer(parser.root)
        var childIndex = indexer
        for op in ops {
            childIndex = childIndex[op.key]
            if op.index >= 0 {
                childIndex = childIndex[op.index]
            }
        }
        ops.removeAll(keepCapacity: false)
        return childIndex
    }

    func stringify() -> String {
        var s = ""
        for op in ops {
            s += "[" + op.toString() + "]"
        }
        return s
    }
}

/// Returned from SWXMLHash, allows easy element lookup into XML data.
public enum XMLIndexer : SequenceType {
    case Element(XMLElement)
    case List([XMLElement])
    case Stream(IndexOps)
    case Error(NSError)

    /// The underlying XMLElement at the currently indexed level of XML.
    public var element: XMLElement? {
        get {
            switch self {
            case .Element(let elem):
                return elem
            case .Stream(let ops):
                let list = ops.findElements()
                return list.element
            default:
                return nil
            }
        }
    }

    /// All elements at the currently indexed level
    public var all: [XMLIndexer] {
        get {
            switch self {
            case .List(let list):
                var xmlList = [XMLIndexer]()
                for elem in list {
                    xmlList.append(XMLIndexer(elem))
                }
                return xmlList
            case .Element(let elem):
                return [XMLIndexer(elem)]
            case .Stream(let ops):
                let list = ops.findElements()
                return list.all
            default:
                return []
            }
        }
    }

    /// All child elements from the currently indexed level
    public var children: [XMLIndexer] {
        get {
            var list = [XMLIndexer]()
            for elem in all.map({ $0.element! }) {
                for elem in elem.children {
                    list.append(XMLIndexer(elem))
                }
            }
            return list
        }
    }

    /**
    Allows for element lookup by matching attribute values.

    :param: attr should the name of the attribute to match on
    :param: _ should be the value of the attribute to match on

    :returns: instance of XMLIndexer
    */
    public func withAttr(attr: String, _ value: String) -> XMLIndexer {
        let attrUserInfo = [NSLocalizedDescriptionKey: "XML Attribute Error: Missing attribute [\"\(attr)\"]"]
        let valueUserInfo = [NSLocalizedDescriptionKey: "XML Attribute Error: Missing attribute [\"\(attr)\"] with value [\"\(value)\"]"]
        switch self {
        case .Stream(let opStream):
            opStream.stringify()
            let match = opStream.findElements()
            return match.withAttr(attr, value)
        case .List(let list):
            if let elem = list.filter({$0.attributes[attr] == value}).first {
                return .Element(elem)
            }
            return .Error(NSError(domain: "SWXMLDomain", code: 1000, userInfo: valueUserInfo))
        case .Element(let elem):
            if let attr = elem.attributes[attr] {
                if attr == value {
                    return .Element(elem)
                }
                return .Error(NSError(domain: "SWXMLDomain", code: 1000, userInfo: valueUserInfo))
            }
            return .Error(NSError(domain: "SWXMLDomain", code: 1000, userInfo: attrUserInfo))
        default:
            return .Error(NSError(domain: "SWXMLDomain", code: 1000, userInfo: attrUserInfo))
        }
    }

    /**
    Initializes the XMLIndexer

    :param: _ should be an instance of XMLElement, but supports other values for error handling

    :returns: instance of XMLIndexer
    */
    public init(_ rawObject: AnyObject) {
        switch rawObject {
        case let value as XMLElement:
            self = .Element(value)
        case let value as LazyXMLParser:
            self = .Stream(IndexOps(parser: value))
        default:
            self = .Error(NSError(domain: "SWXMLDomain", code: 1000, userInfo: nil))
        }
    }

    /**
    Find an XML element at the current level by element name

    :param: key The element name to index by

    :returns: instance of XMLIndexer to match the element (or elements) found by key
    */
    public subscript(key: String) -> XMLIndexer {
        get {
            let userInfo = [NSLocalizedDescriptionKey: "XML Element Error: Incorrect key [\"\(key)\"]"]
            switch self {
            case .Stream(let opStream):
                let op = IndexOp(key)
                opStream.ops.append(op)
                return .Stream(opStream)
            case .Element(let elem):
                let match = elem.children.filter({ $0.name == key })
                if match.count > 0 {
                    if match.count == 1 {
                        return .Element(match[0])
                    }
                    else {
                        return .List(match)
                    }
                }
                return .Error(NSError(domain: "SWXMLDomain", code: 1000, userInfo: userInfo))
            default:
                return .Error(NSError(domain: "SWXMLDomain", code: 1000, userInfo: userInfo))
            }
        }
    }

    /**
    Find an XML element by index within a list of XML Elements at the current level

    :param: index The 0-based index to index by

    :returns: instance of XMLIndexer to match the element (or elements) found by key
    */
    public subscript(index: Int) -> XMLIndexer {
        get {
            let userInfo = [NSLocalizedDescriptionKey: "XML Element Error: Incorrect index [\"\(index)\"]"]
            switch self {
            case .Stream(let opStream):
                opStream.ops[opStream.ops.count - 1].index = index
                return .Stream(opStream)
            case .List(let list):
                if index <= list.count {
                    return .Element(list[index])
                }
                return .Error(NSError(domain: "SWXMLDomain", code: 1000, userInfo: userInfo))
            case .Element(let elem):
                if index == 0 {
                    return .Element(elem)
                }
                else {
                    return .Error(NSError(domain: "SWXMLDomain", code: 1000, userInfo: userInfo))
                }
            default:
                return .Error(NSError(domain: "SWXMLDomain", code: 1000, userInfo: userInfo))
            }
        }
    }

    typealias GeneratorType = XMLIndexer

    public func generate() -> IndexingGenerator<[XMLIndexer]> {
        return all.generate()
    }
}

/// XMLIndexer extensions
extension XMLIndexer: BooleanType {
    /// True if a valid XMLIndexer, false if an error type
    public var boolValue: Bool {
        get {
            switch self {
            case .Error:
                return false
            default:
                return true
            }
        }
    }
}

extension XMLIndexer: Printable {
    public var description: String {
        get {
            switch self {
            case .List(let list):
                return "\n".join(list.map { $0.description })
            case .Element(let elem):
                if elem.name == rootElementName {
                    return "\n".join(elem.children.map { $0.description })
                }

                return elem.description
            default:
                return ""
            }
        }
    }
}

/// Models an XML element, including name, text and attributes
public class XMLElement {
    /// The name of the element
    public let name: String
    /// The inner text of the element, if it exists
    public var text: String?
    /// The attributes of the element
    public var attributes = [String:String]()

    var children = [XMLElement]()
    var count: Int = 0
    var index: Int

    /**
    Initialize an XMLElement instance

    :param: name The name of the element to be initialized

    :returns: a new instance of XMLElement
    */
    init(name: String, index: Int = 0) {
        self.name = name
        self.index = index
    }

    /**
    Adds a new XMLElement underneath this instance of XMLElement

    :param: name The name of the new element to be added
    :param: withAttributes The attributes dictionary for the element being added

    :returns: The XMLElement that has now been added
    */
    func addElement(name: String, withAttributes attributes: NSDictionary) -> XMLElement {
        let element = XMLElement(name: name, index: count)
        count++

        children.append(element)

        for (keyAny,valueAny) in attributes {
            let key = keyAny as! String
            let value = valueAny as! String
            element.attributes[key] = value
        }

        return element
    }
}

extension XMLElement: Printable {
    public var description:String {
        get {
            var attributesStringList = [String]()
            if !attributes.isEmpty {
                for (key, val) in attributes {
                    attributesStringList.append("\(key)=\"\(val)\"")
                }
            }

            var attributesString = " ".join(attributesStringList)
            if (!attributesString.isEmpty) {
                attributesString = " " + attributesString
            }

            if children.count > 0 {
                var xmlReturn = [String]()
                xmlReturn.append("<\(name)\(attributesString)>")
                for child in children {
                    xmlReturn.append(child.description)
                }
                xmlReturn.append("</\(name)>")
                return "\n".join(xmlReturn)
            }

            if text != nil {
                return "<\(name)\(attributesString)>\(text!)</\(name)>"
            }
            else {
                return "<\(name)\(attributesString)/>"
            }
        }
    }
}

//MARK: - Natalie

//MARK: Objects
enum OS: String, Printable {
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
            self = iOS
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
        case iOS:
            return "UIStoryboard"
        case OSX:
            return "NSStoryboard"
        }
    }

    var storyboardSegueType: String {
        switch self {
        case iOS:
            return "UIStoryboardSegue"
        case OSX:
            return "NSStoryboardSegue"
        }
    }
    
    var storyboardTypeUnwrap: String {
        switch self {
        case iOS:
            return ""
        case OSX:
            return "!"
        }
    }

    var storyboardSegueUnwrap: String {
        switch self {
        case iOS:
            return ""
        case OSX:
            return "!"
        }
    }
    
    var storyboardControllerTypes: [String] {
        switch self {
        case iOS:
            return ["UIViewController"]
        case OSX:
            return ["NSViewController", "NSWindowController"]
        }
    }
    
    var storyboardControllerSignatureType: String {
        switch self {
        case iOS:
            return "ViewController"
        case OSX:
            return "Controller" // NSViewController or NSWindowController
        }
    }
    
    var viewType: String {
        switch self {
        case iOS:
            return "UIView"
        case OSX:
            return "NSView"
        }
    }
    
    var resuableViews: [String]? {
        switch self {
        case iOS:
            return ["UICollectionReusableView","UITableViewCell"]
        case OSX:
            return nil
        }
    }
    
    var storyboardControllerReturnType: String {
        switch self {
        case iOS:
            return "UIViewController"
        case OSX:
            return "AnyObject" // NSViewController or NSWindowController
        }
    }
    
    var storyboardControllerInitialReturnTypeCast: String {
        switch self {
        case iOS:
            return "as? \(self.storyboardControllerReturnType)"
        case OSX:
            return ""
        }
    }
    
    var storyboardControllerReturnTypeCast: String {
        switch self {
        case iOS:
            return " as! \(self.storyboardControllerReturnType)"
        case OSX:
            return "!"
        }
    }
    
    func storyboardControllerInitialReturnTypeCast(initialClass: String) -> String {
        switch self {
        case iOS:
            return "as! \(initialClass)"
        case OSX:
            return ""
        }
    }

    func controllerTypeForElementName(name: String) -> String? {
        switch self {
        case iOS:
            switch name {
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
            default:
                return nil
            }
        case OSX:
            switch name {
            case "pagecontroller":
                return "NSPageController"
            case "tabViewController":
                return "NSTabViewController"
            case "splitViewController":
                return "NSSplitViewController"
            default:
                return nil
            }
        }
    }

}

class XMLObject {

    var xml: XMLIndexer

    lazy var name: String? = self.xml.element?.name
    
    init(xml: XMLIndexer) {
        self.xml = xml
    }

    func searchAll(attributeKey: String, attributeValue: String? = nil) -> [XMLIndexer]? {
        return searchAll(self.xml, attributeKey: attributeKey, attributeValue: attributeValue)
    }

    func searchAll(root: XMLIndexer, attributeKey: String, attributeValue: String? = nil) -> [XMLIndexer]? {
        var result = Array<XMLIndexer>()
        for child in root.children {
            
            for childAtLevel in child.all {
                if let attributeValue = attributeValue {
                    if let element = childAtLevel.element where element.attributes[attributeKey] == attributeValue {
                        result += [childAtLevel]
                    }
                } else if let element = childAtLevel.element where element.attributes[attributeKey] != nil {
                    result += [childAtLevel]
                }
                
                if let found = searchAll(childAtLevel, attributeKey: attributeKey, attributeValue: attributeValue) {
                    result += found
                }
            }
        }
        return result.count > 0 ? result : nil
    }
    
    func searchNamed(name: String) -> [XMLIndexer]? {
        return self.searchNamed(self.xml, name: name)
    }

    func searchNamed(root: XMLIndexer, name: String) -> [XMLIndexer]? {
        var result = Array<XMLIndexer>()
        for child in root.children {
            
            for childAtLevel in child.all {
                if let elementName = childAtLevel.element?.name where elementName == name {
                    result += [child]
                }
                if let found = searchNamed(childAtLevel, name: name) {
                    result += found
                }
            }
        }
        return result.count > 0 ? result : nil
    }

    func searchById(id: String) -> XMLIndexer? {
        return searchAll("id", attributeValue: id)?.first
    }
}

class Scene: XMLObject {
    
    lazy var viewController: ViewController? = {
        if let vcs = self.searchAll("sceneMemberID", attributeValue: "viewController"), vc = vcs.first {
            return ViewController(xml: vc)
        }
        return nil
    }()
    
    lazy var segues: [Segue]? = {
        return self.searchNamed("segue")?.map { Segue(xml: $0) }
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
        if let reusables = self.searchAll(self.xml, attributeKey: "reuseIdentifier"){
            return reusables.map { Reusable(xml: $0) }
        }
        return nil
        }()
}

class Segue: XMLObject {
 
    lazy var identifier: String? = self.xml.element?.attributes["identifier"]
    lazy var kind: String? = self.xml.element?.attributes["kind"]
    lazy var destination: String? = self.xml.element?.attributes["destination"]
}

class Reusable: XMLObject {
    
    lazy var reuseIdentifier: String? = self.xml.element?.attributes["reuseIdentifier"]
    lazy var customClass: String? = self.xml.element?.attributes["customClass"]
    lazy var kind: String? = self.xml.element?.name
}

class Storyboard: XMLObject {
    
    lazy var os:OS = self.initOS() ?? OS.iOS
    private func initOS() -> OS? {
        if let targetRuntime = self.xml["document"].element?.attributes["targetRuntime"] {
            return OS(targetRuntime: targetRuntime)
        }
        return nil
    }
    
    lazy var initialViewControllerClass: String? = self.initInitialViewControllerClass()
    private func initInitialViewControllerClass() -> String? {
        if let initialViewControllerId = xml["document"].element?.attributes["initialViewController"],
            xmlVC = searchById(initialViewControllerId)
        {
            let vc = ViewController(xml: xmlVC)
            if let customClassName = vc.customClass {
                return customClassName
            }
            
            if let name = vc.name, controllerType = os.controllerTypeForElementName(name) {
                return controllerType
            }
        }
        return nil
    }
    
    lazy var version: String? = self.xml["document"].element?.attributes["version"]
    
    lazy var scenes: [Scene] = {
        if let scenes = self.searchAll(self.xml, attributeKey: "sceneID"){
            return scenes.map { Scene(xml: $0) }
        }
        return []
    }()
    
    lazy var customModules: [String] = self.scenes.filter{ $0.customModule != nil && $0.customModuleProvider == nil  }.map{ $0.customModule! }

    func processStoryboard(storyboardName: String, os: OS) {
        println()
        println("    struct \(storyboardName) {")
        println()
        println("        static let identifier = \"\(storyboardName)\"")
        println()
        println("        static var storyboard: \(os.storyboardType) {")
        println("            return \(os.storyboardType)(name: self.identifier, bundle: nil)\(os.storyboardTypeUnwrap)")
        println("        }")
        if let initialViewControllerClass = self.initialViewControllerClass {
            println()
            println("        static func instantiateInitial\(os.storyboardControllerSignatureType)() -> \(initialViewControllerClass)! {")
            println("            return self.storyboard.instantiateInitial\(os.storyboardControllerSignatureType)() \(os.storyboardControllerInitialReturnTypeCast(initialViewControllerClass))")
            println("        }")
        }
        println()
        println("        static func instantiate\(os.storyboardControllerSignatureType)WithIdentifier(identifier: String) -> \(os.storyboardControllerReturnType) {")
        println("            return self.storyboard.instantiate\(os.storyboardControllerSignatureType)WithIdentifier(identifier)\(os.storyboardControllerReturnTypeCast)")
        println("        }")
        for scene in self.scenes {
            if let viewController = scene.viewController, customClass = viewController.customClass, storyboardIdentifier = viewController.storyboardIdentifier {
                println()
                println("        static func instantiate\(storyboardIdentifier.trimAllWhitespacesAndSpecialCharacters)() -> \(customClass)! {")
                println("            return self.storyboard.instantiate\(os.storyboardControllerSignatureType)WithIdentifier(\"\(storyboardIdentifier)\") as! \(customClass)")
                println("        }")
            }
        }
        println("    }")
    }
    
    func processViewControllers() {
        for scene in self.scenes {
            if let viewController = scene.viewController {
                if let customClass = viewController.customClass {
                    println()
                    println("//MARK: - \(customClass)")

                    if let segues = scene.segues?.filter({ return $0.identifier != nil })
                        where segues.count > 0 {
                            println("extension \(os.storyboardSegueType) {")
                            println("    func selection() -> \(customClass).Segue? {")
                            println("        if let identifier = self.identifier {")
                            println("            return \(customClass).Segue(rawValue: identifier)")
                            println("        }")
                            println("        return nil")
                            println("    }")
                            println("}")
                            println()
                    }
                    
                    if let segues = scene.segues?.filter({ return $0.identifier != nil })
                        where segues.count > 0 {
                            println("extension \(customClass) { ")
                            println()
                            println("    enum Segue: String, Printable, SegueProtocol {")
                            for segue in segues {
                                if let identifier = segue.identifier
                                {
                                    println("        case \(identifier.trimAllWhitespacesAndSpecialCharacters) = \"\(identifier)\"")
                                }
                            }
                            println()
                            println("        var kind: SegueKind? {")
                            println("            switch (self) {")
                            for segue in segues {
                                if let identifier = segue.identifier, kind = segue.kind {
                                    println("            case \(identifier.trimAllWhitespacesAndSpecialCharacters):")
                                    println("                return SegueKind(rawValue: \"\(kind)\")")
                                }
                            }
                            println("            default:")
                            println("                preconditionFailure(\"Invalid value\")")
                            println("                break")
                            println("            }")
                            println("        }")
                            println()
                            println("        var destination: \(self.os.storyboardControllerReturnType).Type? {")
                            println("            switch (self) {")
                            for segue in segues {
                                if let identifier = segue.identifier, destination = segue.destination,
                                    destinationCustomClass = searchById(destination)?.element?.attributes["customClass"]
                                {
                                    println("            case \(identifier.trimAllWhitespacesAndSpecialCharacters):")
                                    println("                return \(destinationCustomClass).self")                                
                                }
                            }
                            println("            default:")
                            println("                assertionFailure(\"Unknown destination\")")                                
                            println("                return nil")        
                            println("            }")
                            println("        }")
                            println()
                            println("        var identifier: String? { return self.description } ")
                            println("        var description: String { return self.rawValue }")
                            println("    }")
                            println()
                            println("}")
                    }

                    if let reusables = viewController.reusables?.filter({ return $0.reuseIdentifier != nil })
                        where reusables.count > 0 {
                            
                            println("extension \(customClass) { ")
                            println()
                            println("    enum Reusable: String, Printable, ReusableViewProtocol {")
                            for reusable in reusables {
                                if let identifier = reusable.reuseIdentifier
                                {
                                    println("        case \(identifier) = \"\(identifier)\"")
                                }
                            }
                            println()
                            println("        var kind: ReusableKind? {")
                            println("            switch (self) {")
                            for reusable in reusables {
                                if let identifier = reusable.reuseIdentifier, kind = reusable.kind {
                                    println("            case \(identifier):")
                                    println("                return ReusableKind(rawValue: \"\(kind)\")")
                                }
                            }
                            println("            default:")
                            println("                preconditionFailure(\"Invalid value\")")
                            println("                break")
                            println("            }")
                            println("        }")
                            println()
                            println("        var viewType: \(self.os.viewType).Type? {")
                            println("            switch (self) {")
                            for reusable in reusables {
                                if let identifier = reusable.reuseIdentifier, customClass = reusable.customClass
                                {
                                    println("            case \(identifier):")
                                    println("                return \(customClass).self")
                                }
                            }
                            println("            default:")
                            println("                return nil")
                            println("            }")
                            println("        }")
                            println()
                            println("        var identifier: String? { return self.description } ")
                            println("        var description: String { return self.rawValue }")
                            println("    }")
                            println()
                            println("}\n")
                    }
                }
            }
        }
    }
}

class StoryboardFile {

    let filePath: String
    init(filePath: String){
        self.filePath = filePath
    }

    lazy var storyboardName: String = self.filePath.lastPathComponent.stringByDeletingPathExtension
    
    lazy var data: NSData? = NSData(contentsOfFile: self.filePath)
    lazy var xml: XMLIndexer? = {
        if let d = self.data {
            return SWXMLHash.parse(d)
        }
        return nil
        }()
    
    lazy var storyboard: Storyboard? = {
        if let xml = self.xml {
            return Storyboard(xml:xml)
        }
        return nil
        }()
}


//MARK: Functions

func findStoryboards(rootPath: String, suffix: String) -> [String]? {
    var result = Array<String>()
    let fm = NSFileManager.defaultManager()
    var error:NSError?
    if let paths = fm.subpathsAtPath(rootPath) as? [String]  {
        let storyboardPaths = paths.filter({ return $0.hasSuffix(suffix)})
        // result = storyboardPaths
        for p in storyboardPaths {
            result.append(rootPath.stringByAppendingPathComponent(p))
        }
    }
    return result.count > 0 ? result : nil
}

func processStoryboards(storyboards: [StoryboardFile], os: OS) {
    
    println("//")
    println("// Autogenerated by Natalie - Storyboard Generator Script.")
    println("// http://blog.krzyzanowskim.com")
    println("//")
    println()
    println("import \(os.framework)")
    let modules = storyboards.filter{ $0.storyboard != nil }.flatMap{ $0.storyboard!.customModules }
    for module in Set<String>(modules) {
        println("import \(module)")
    }
    println()
    
    println("//MARK: - Storyboards")
    println("struct Storyboards {")
    for file in storyboards {
        file.storyboard?.processStoryboard(file.storyboardName, os: os)
    }
    println("}")
    println()
    
    println("//MARK: - ReusableKind")
    println("enum ReusableKind: String, Printable {")
    println("    case TableViewCell = \"tableViewCell\"")
    println("    case CollectionViewCell = \"collectionViewCell\"")
    println()
    println("    var description: String { return self.rawValue }")
    println("}")
    println()
    
    println("//MARK: - SegueKind")
    println("enum SegueKind: String, Printable {    ")
    println("    case Relationship = \"relationship\" ")
    println("    case Show = \"show\"                 ")
    println("    case Presentation = \"presentation\" ")
    println("    case Embed = \"embed\"               ")
    println("    case Unwind = \"unwind\"             ")
    println()
    println("    var description: String { return self.rawValue } ")
    println("}")
    println()
    
    println("//MARK: - SegueProtocol")
    println("public protocol IdentifiableProtocol: Equatable {")
    println("    var identifier: String? { get }")
    println("}")
    println()
    println("public protocol SegueProtocol: IdentifiableProtocol {")
    println("}")
    println()
    
    println("public func ==<T: SegueProtocol, U: SegueProtocol>(lhs: T, rhs: U) -> Bool {")
    println("   return lhs.identifier == rhs.identifier")
    println("}")
    println()
    println("public func ~=<T: SegueProtocol, U: SegueProtocol>(lhs: T, rhs: U) -> Bool {")
    println("   return lhs.identifier == rhs.identifier")
    println("}")
    println()
    println("public func ==<T: SegueProtocol>(lhs: T, rhs: String) -> Bool {")
    println("   return lhs.identifier == rhs")
    println("}")
    println()
    println("public func ~=<T: SegueProtocol>(lhs: T, rhs: String) -> Bool {")
    println("   return lhs.identifier == rhs")
    println("}")
    println()
    
    println("//MARK: - ReusableViewProtocol")
    println("public protocol ReusableViewProtocol: IdentifiableProtocol {")
    println("    var viewType: \(os.viewType).Type? {get}")
    println("}")
    println()
    
    println("public func ==<T: ReusableViewProtocol, U: ReusableViewProtocol>(lhs: T, rhs: U) -> Bool {")
    println("   return lhs.identifier == rhs.identifier")
    println("}")
    println()
    
    println("//MARK: - Protocol Implementation")
    println("extension \(os.storyboardSegueType): SegueProtocol {")
    println("}")
    println()
    
    if let reusableViews = os.resuableViews {
        for reusableView in reusableViews {
            println("extension \(reusableView): ReusableViewProtocol {")
            println("    public var viewType: UIView.Type? { return self.dynamicType}")
            println("    public var identifier: String? { return self.reuseIdentifier}")
            println("}")
            println()
        }
    }
    
    for controllerType in os.storyboardControllerTypes {
        println("//MARK: - \(controllerType) extension")
        println("extension \(controllerType) {")
        println("    func performSegue<T: SegueProtocol>(segue: T, sender: AnyObject?) {")
        println("       performSegueWithIdentifier(segue.identifier\(os.storyboardSegueUnwrap), sender: sender)")
        println("    }")
        println()
        println("    func performSegue<T: SegueProtocol>(segue: T) {")
        println("       performSegue(segue, sender: nil)")
        println("    }")
        println("}")
        println()
    }
  
    if os == OS.iOS {
        println("//MARK: - UICollectionView")
        println()
        println("extension UICollectionView {")
        println()
        println("    func dequeueReusableCell<T: ReusableViewProtocol>(reusable: T, forIndexPath: NSIndexPath!) -> UICollectionViewCell? {")
        println("        if let identifier = reusable.identifier {")
        println("            return dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: forIndexPath) as? UICollectionViewCell")
        println("        }")
        println("        return nil")
        println("    }")
        println()
        println("    func registerReusableCell<T: ReusableViewProtocol>(reusable: T) {")
        println("        if let type = reusable.viewType, identifier = reusable.identifier {")
        println("            registerClass(type, forCellWithReuseIdentifier: identifier)")
        println("        }")
        println("    }")
        println()
        println("    func dequeueReusableSupplementaryViewOfKind<T: ReusableViewProtocol>(elementKind: String, withReusable reusable: T, forIndexPath: NSIndexPath!) -> UICollectionReusableView? {")
        println("        if let identifier = reusable.identifier {")
        println("            return dequeueReusableSupplementaryViewOfKind(elementKind, withReuseIdentifier: identifier, forIndexPath: forIndexPath) as? UICollectionReusableView")
        println("        }")
        println("        return nil")
        println("    }")
        println()
        println("    func registerReusable<T: ReusableViewProtocol>(reusable: T, forSupplementaryViewOfKind elementKind: String) {")
        println("        if let type = reusable.viewType, identifier = reusable.identifier {")
        println("            registerClass(type, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: identifier)")
        println("        }")
        println("    }")
        println("}")
    
        println("//MARK: - UITableView")
        println()
        println("extension UITableView {")
        println()
        println("    func dequeueReusableCell<T: ReusableViewProtocol>(reusable: T, forIndexPath: NSIndexPath!) -> UITableViewCell? {")
        println("        if let identifier = reusable.identifier {")
        println("            return dequeueReusableCellWithIdentifier(identifier, forIndexPath: forIndexPath) as? UITableViewCell")
        println("        }")
        println("        return nil")
        println("    }")
        println()
        println("    func registerReusableCell<T: ReusableViewProtocol>(reusable: T) {")
        println("        if let type = reusable.viewType, identifier = reusable.identifier {")
        println("            registerClass(type, forCellReuseIdentifier: identifier)")
        println("        }")
        println("    }")
        println()
        println("    func dequeueReusableHeaderFooter<T: ReusableViewProtocol>(reusable: T) -> UITableViewHeaderFooterView? {")
        println("        if let identifier = reusable.identifier {")
        println("            return dequeueReusableHeaderFooterViewWithIdentifier(identifier) as? UITableViewHeaderFooterView")
        println("        }")
        println("        return nil")
        println("    }")
        println()
        println("    func registerReusableHeaderFooter<T: ReusableViewProtocol>(reusable: T) {")
        println("        if let type = reusable.viewType, identifier = reusable.identifier {")
        println("             registerClass(type, forHeaderFooterViewReuseIdentifier: identifier)")
        println("        }")
        println("    }")
        println("}")
        println()
    }

    for file in storyboards {
        file.storyboard?.processViewControllers()
    }

}

//MARK: MAIN()

if Process.arguments.count == 1 {
    println("Invalid usage. Missing path to storyboard.")
    exit(0)
}

let argument = Process.arguments[1]
var storyboards:[String] = []
let storyboardSuffix = ".storyboard"
if argument.hasSuffix(storyboardSuffix) {
    storyboards = [argument]
} else if let s = findStoryboards(argument, storyboardSuffix) {
    storyboards = s
}
let storyboardFiles: [StoryboardFile] = storyboards.map { StoryboardFile(filePath: $0) }

for os in OS.allValues {
    var storyboardsForOS = storyboardFiles.filter { $0.storyboard?.os == os }
    if !storyboardsForOS.isEmpty {
        
        if storyboardsForOS.count != storyboardFiles.count {
            println("#if os(\(os.rawValue))")
        }
        
        processStoryboards(storyboardsForOS, os)
        
        if storyboardsForOS.count != storyboardFiles.count {
            println("#endif")
        }
    }
}

