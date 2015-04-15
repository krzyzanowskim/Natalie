#!/usr/bin/env xcrun swift -F Rome

//
// Natalie - Storyboard Generator Script
//
// Generate swift file based on storyboard files
// to make work with Storyboards and segues easier with Swift. 
// Generated file reduce usage of String as identifiers for 
// Segues or Storyboards.
// 
// Instantiate ViewController for storyboard
// let vc = Storyboards.Main.instantiateInitialViewController() as? MainViewController
//
// Perform segue:
// self.performSegueWithIdentifier(myViewController.Segue.GoToDetails, sender:nil)
//
// Usage:
// natalie.swift Main.storyboard > Storyboards.swift
// natalie.swift path/toproject/with/storyboards > Storyboards.swift
//
// Licence: MIT
// Author: Marcin Krzyżanowski http://blog.krzyzanowskim.com
//

import Foundation
import SWXMLHash

private func searchAll(root: XMLIndexer, attributeKey: String, attributeValue: String) -> [XMLIndexer]? {
    var result = Array<XMLIndexer>()
    for child in root.children {
        if let element = child.element where element.attributes[attributeKey] == attributeValue {
            return [child]
        }
        if let found = searchAll(child, attributeKey, attributeValue) {
            result += found
        }
    }
    return result.count > 0 ? result : nil
}

func findStoryboards(rootPath: String) -> [String]? {
    //let bundleRoot = NSBundle.mainBundle().bundlePath
    let fm = NSFileManager.defaultManager()
    var error:NSError?
    if let dirContents = fm.contentsOfDirectoryAtPath(rootPath, error:&error) as? [String] {
        return dirContents.filter({ return $0.hasSuffix(".storyboard")})
    }
    return nil
}

func findInitialViewControllerClass(storyboardFile: String) -> String? {
    if let data = NSData(contentsOfFile: storyboardFile) {
        let xml = SWXMLHash.parse(data)
        if let initialViewControllerId = xml["document"].element?.attributes["initialViewController"] {
            if let vc = searchAll(xml["document"], "id",initialViewControllerId)?.first {

                if let customClassName = vc.element?.attributes["customClass"] {
                    return customClassName
                }

                switch (vc.element!.name) {
                    case "navigationController":
                        return "UINavigationController"
                    case "tableViewController":
                        return "UITableViewController"
                    case "tableViewController":
                        return "UITableViewController"
                    default:
                        break
                }
            }
        }
    }
    return nil
}

func processStoryboard(storyboardFile: String) {
    if let data = NSData(contentsOfFile: storyboardFile) {
        let xml = SWXMLHash.parse(data)

        if let viewControllers = searchAll(xml, "sceneMemberID", "viewController") {
            for viewController in viewControllers {
                if let customClass = viewController.element?.attributes["customClass"], let viewControllerId = viewController.element?.attributes["id"]  {
                    println("//MARK: - \(customClass)")
                    println("extension \(customClass) { ")
                    println("    var storyboardIdentifier:String { return \"\(viewControllerId)\" }")
                    let segues = viewController["connections"]["segue"].all.filter({ return $0.element?.attributes["identifier"] != nil })
                    if segues.count > 0 {
                        println()
                        println("    enum Segue: String, Printable, SegueProtocol {")
                        for segue in segues {
                            if let identifier = segue.element?.attributes["identifier"]
                            {
                                println("        case \(identifier) = \"\(identifier)\"")
                            }
                        }
                        // println("        var kind: SegueKind { return SegueKind(rawValue: \"\(kind)\") }")
                        println()
                        println("        var kind: SegueKind? {")
                        println("            switch (self) {")
                        for segue in segues {
                            if let identifier = segue.element?.attributes["identifier"],
                               let kind = segue.element?.attributes["kind"] {
                                println("            case \(identifier):")
                                println("                return SegueKind(rawValue: \"\(kind)\")")
                            }
                        }
                        println("            default:")
                        println("                preconditionFailure(\"Invalid value\")")
                        println("                break")
                        println("            }")
                        println("        }")
                        println()
                        println("        var destination: UIViewController.Type? {")
                        println("            switch (self) {")
                        for segue in segues {
                            if let identifier = segue.element?.attributes["identifier"],
                               let destination = segue.element?.attributes["destination"],
                               let destinationCustomClass = searchAll(xml, "id", destination)?.first?.element?.attributes["customClass"] {

                                // let dstCustomClass = destinationViewController.element!.attributes["customClass"]
                                println("            case \(identifier):")
                                println("                return \(destinationCustomClass).self")                                
                            }
                        }
                        println("            default:")
                        println("                assertionFailure(\"Unknown destination\")")                                
                        println("                return nil")        
                        println("            }")
                        println("        }")
                        println()
                        println("        var identifier: String { return self.description } ")
                        println("        var description: String { return self.rawValue }")
                        println("    }")
                        println()
                    }
                    println("}\n")
                }
            }
        }
    }
}

//MARK: MAIN()

if Process.arguments.count == 1 {
    println("Invalid usage. Missing path to storyboard.")
    exit(0)
}

let argument = Process.arguments[1]
var storyboards:[String] = []
if argument.hasSuffix(".storyboard") {
    storyboards = [argument]
} else if let s = findStoryboards(argument) {
    storyboards = s
}

println("//")
println("// Autogenerated by Natalie - Storyboard Generator Script.")
println("// http://blog.krzyzanowskim.com")
println("//")
println()
println("//MARK: - Storyboards")
println("enum Storyboards: String {")
for storyboard in storyboards {
    let storyboardName = storyboard.lastPathComponent.stringByDeletingPathExtension
    println("    case \(storyboardName) = \"\(storyboardName)\"")
}
println()    
println("    private var instance:UIStoryboard {")
println("        return UIStoryboard(name: self.rawValue, bundle: nil)")
println("    }")
println()    
println("    func instantiateInitialViewController() -> UIViewController {")
for storyboard in storyboards {
    let storyboardName = storyboard.lastPathComponent.stringByDeletingPathExtension
    println("        switch (self) {")
    if let initialViewControllerClass = findInitialViewControllerClass(storyboard) {
        println("        case \(storyboardName):")
        println("            return self.instance.instantiateInitialViewController() as \(initialViewControllerClass)")
    }
    println("        default:")
    println("            return self.instance.instantiateInitialViewController() as UIViewController")
    println("        }")
}
println("    }")
println()    
println("    func instantiateViewControllerWithIdentifier(identifier: String) -> UIViewController {")
println("        return self.instance.instantiateViewControllerWithIdentifier(identifier) as UIViewController")
println("    }")
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
println("protocol SegueProtocol {")
println("    var identifier: String { get }")
println("}")
println()

println("//MARK: - UIViewController extension")
println("extension UIViewController {")
println("    func performSegue(segue: SegueProtocol, sender: AnyObject?) {")
println("       performSegueWithIdentifier(segue.identifier, sender: sender)")
println("    }")
println("}")
println()

for storyboard in storyboards {
    processStoryboard(storyboard)
}

