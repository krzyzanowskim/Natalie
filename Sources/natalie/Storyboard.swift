//
//  Storyboard.swift
//  Natalie
//
//  Created by Marcin Krzyzanowski on 07/08/16.
//  Copyright © 2016 Marcin Krzyzanowski. All rights reserved.
//

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

