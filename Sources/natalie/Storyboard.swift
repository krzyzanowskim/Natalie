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

    func processStoryboard(storyboardName: String, os: OS) -> String {
        var output = String()

        output += ""
        output += "    struct \(storyboardName): Storyboard {"
        output += ""
        output += "        static let identifier = \"\(storyboardName)\""
        output += ""
        output += "        static var storyboard: \(os.storyboardType) {"
        output += "            return \(os.storyboardType)(name: self.identifier, bundle: nil)"
        output += "        }"
        if let initialViewControllerClass = self.initialViewControllerClass {
            let cast = (initialViewControllerClass == os.storyboardControllerReturnType ? (os == OS.iOS ? "!" : "") : " as! \(initialViewControllerClass)")
            output += ""
            output += "        static func instantiateInitial\(os.storyboardControllerSignatureType)() -> \(initialViewControllerClass) {"
            output += "            return self.storyboard.instantiateInitial\(os.storyboardControllerSignatureType)()\(cast)"
            output += "        }"
        }
        for (signatureType, returnType) in os.storyboardInstantiationInfo {
            let cast = (returnType == os.storyboardControllerReturnType ? "" : " as! \(returnType)")
            output += ""
            output += "        static func instantiate\(signatureType)WithIdentifier(identifier: String) -> \(returnType) {"
            output += "            return self.storyboard.instantiate\(signatureType)WithIdentifier(identifier)\(cast)"
            output += "        }"

            output += ""
            output += "        static func instantiateViewController<T: \(returnType) where T: IdentifiableProtocol>(type: T.Type) -> T? {"
            output += "            return self.storyboard.instantiateViewController(type)"
            output += "        }"
        }
        for scene in self.scenes {
            if let viewController = scene.viewController, let storyboardIdentifier = viewController.storyboardIdentifier {
                let controllerClass = (viewController.customClass ?? os.controllerTypeForElementName(name: viewController.name)!)
                let cast = (controllerClass == os.storyboardControllerReturnType ? "" : " as! \(controllerClass)")
                output += ""
                output += "        static func instantiate\(SwiftRepresentationForString(string: storyboardIdentifier, capitalizeFirstLetter: true))() -> \(controllerClass) {"
                output += "            return self.storyboard.instantiate\(os.storyboardControllerSignatureType)WithIdentifier(\"\(storyboardIdentifier)\")\(cast)"
                output += "        }"
            }
        }
        output += "    }"

        return output
    }

    func processViewControllers() -> String {
        var output = String()

        for scene in self.scenes {
            if let viewController = scene.viewController {
                if let customClass = viewController.customClass {
                    output += ""
                    output += "//MARK: - \(customClass)"

                    if let segues = scene.segues?.filter({ return $0.identifier != nil }), segues.count > 0 {
                        output += "extension \(os.storyboardSegueType) {"
                        output += "    func selection() -> \(customClass).Segue? {"
                        output += "        if let identifier = self.identifier {"
                        output += "            return \(customClass).Segue(rawValue: identifier)"
                        output += "        }"
                        output += "        return nil"
                        output += "    }"
                        output += "}"
                        output += ""
                    }

                    if let storyboardIdentifier = viewController.storyboardIdentifier {
                        output += "extension \(customClass): IdentifiableProtocol { "
                        if viewController.customModule != nil {
                            output += "    var storyboardIdentifier: String? { return \"\(storyboardIdentifier)\" }"
                        } else {
                            output += "    public var storyboardIdentifier: String? { return \"\(storyboardIdentifier)\" }"
                        }
                        output += "    static var storyboardIdentifier: String? { return \"\(storyboardIdentifier)\" }"
                        output += "}"
                        output += ""
                    }

                    if let segues = scene.segues?.filter({ return $0.identifier != nil }), segues.count > 0 {
                        output += "extension \(customClass) { "
                        output += ""
                        output += "    enum Segue: String, CustomStringConvertible, SegueProtocol {"
                        for segue in segues {
                            if let identifier = segue.identifier
                            {
                                output += "        case \(SwiftRepresentationForString(string: identifier)) = \"\(identifier)\""
                            }
                        }
                        output += ""
                        output += "        var kind: SegueKind? {"
                        output += "            switch (self) {"
                        var needDefaultSegue = false
                        for segue in segues {
                            if let identifier = segue.identifier {
                                output += "            case \(SwiftRepresentationForString(string: identifier)):"
                                output += "                return SegueKind(rawValue: \"\(segue.kind)\")"
                            } else {
                                needDefaultSegue = true
                            }
                        }
                        if needDefaultSegue {
                            output += "            default:"
                            output += "                assertionFailure(\"Invalid value\")"
                            output += "                return nil"
                        }
                        output += "            }"
                        output += "        }"
                        output += ""
                        output += "        var destination: \(self.os.storyboardControllerReturnType).Type? {"
                        output += "            switch (self) {"
                        var needDefaultDestination = false
                        for segue in segues {
                            if let identifier = segue.identifier, let destination = segue.destination,
                                let destinationElement = searchById(id: destination)?.element,
                                let destinationClass = (destinationElement.attributes["customClass"] ?? os.controllerTypeForElementName(name: destinationElement.name))
                            {
                                output += "            case \(SwiftRepresentationForString(string: identifier)):"
                                output += "                return \(destinationClass).self"
                            } else {
                                needDefaultDestination = true
                            }
                        }
                        if needDefaultDestination {
                            output += "            default:"
                            output += "                assertionFailure(\"Unknown destination\")"
                            output += "                return nil"
                        }
                        output += "            }"
                        output += "        }"
                        output += ""
                        output += "        var identifier: String? { return self.description } "
                        output += "        var description: String { return self.rawValue }"
                        output += "    }"
                        output += ""
                        output += "}"
                    }

                    if let reusables = viewController.reusables?.filter({ return $0.reuseIdentifier != nil }), reusables.count > 0 {

                        output += "extension \(customClass) { "
                        output += ""
                        output += "    enum Reusable: String, CustomStringConvertible, ReusableViewProtocol {"
                        for reusable in reusables {
                            if let identifier = reusable.reuseIdentifier {
                                output += "        case \(SwiftRepresentationForString(string: identifier, doNotShadow: reusable.customClass)) = \"\(identifier)\""
                            }
                        }
                        output += ""
                        output += "        var kind: ReusableKind? {"
                        output += "            switch (self) {"
                        var needDefault = false
                        for reusable in reusables {
                            if let identifier = reusable.reuseIdentifier {
                                output += "            case \(SwiftRepresentationForString(string: identifier, doNotShadow: reusable.customClass)):"
                                output += "                return ReusableKind(rawValue: \"\(reusable.kind)\")"
                            } else {
                                needDefault = true
                            }
                        }
                        if needDefault {
                            output += "            default:"
                            output += "                preconditionFailure(\"Invalid value\")"
                            output += "                break"
                        }
                        output += "            }"
                        output += "        }"
                        output += ""
                        output += "        var viewType: \(self.os.viewType).Type? {"
                        output += "            switch (self) {"
                        needDefault = false
                        for reusable in reusables {
                            if let identifier = reusable.reuseIdentifier, let customClass = reusable.customClass {
                                output += "            case \(SwiftRepresentationForString(string: identifier, doNotShadow: reusable.customClass)):"
                                output += "                return \(customClass).self"
                            } else {
                                needDefault = true
                            }
                        }
                        if needDefault {
                            output += "            default:"
                            output += "                return nil"
                        }
                        output += "            }"
                        output += "        }"
                        output += ""
                        output += "        var storyboardIdentifier: String? { return self.description } "
                        output += "        var description: String { return self.rawValue }"
                        output += "    }"
                        output += ""
                        output += "}\n"
                    }
                }
            }
        }
        return output
    }
}

