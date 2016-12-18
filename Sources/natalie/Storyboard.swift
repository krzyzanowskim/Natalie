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

        output += "\n"
        output += "    struct \(storyboardName): Storyboard {\n"
        output += "\n"
        output += "        static let identifier = \"\(storyboardName)\"\n"
        output += "\n"
        output += "        static var storyboard: \(os.storyboardType) {\n"
        output += "            return \(os.storyboardType)(name: self.identifier, bundle: nil)\n"
        output += "        }\n"
        if let initialViewControllerClass = self.initialViewControllerClass {
            let cast = (initialViewControllerClass == os.storyboardControllerReturnType ? (os == OS.iOS ? "!" : "") : " as! \(initialViewControllerClass)")
            output += "\n"
            output += "        static func instantiateInitial\(os.storyboardControllerSignatureType)() -> \(initialViewControllerClass) {\n"
            output += "            return self.storyboard.instantiateInitial\(os.storyboardControllerSignatureType)()\(cast)\n"
            output += "        }\n"
        }
        for (signatureType, returnType) in os.storyboardInstantiationInfo {
            let cast = (returnType == os.storyboardControllerReturnType ? "" : " as! \(returnType)")
            output += "\n"
            output += "        static func instantiate\(signatureType)(withIdentifier: String) -> \(returnType) {\n"
            output += "            return self.storyboard.instantiate\(signatureType)(withIdentifier: identifier)\(cast)\n"
            output += "        }\n"

            output += "\n"
            output += "        static func instantiateViewController<T: \(returnType)>(ofType type: T.Type) -> T? where T: IdentifiableProtocol {\n"
            output += "            return self.storyboard.instantiateViewController(ofType: type)\n"
            output += "        }\n"
        }
        for scene in self.scenes {
            if let viewController = scene.viewController, let storyboardIdentifier = viewController.storyboardIdentifier {
                guard let controllerClass = viewController.customClass ?? os.controllerTypeForElementName(name: viewController.name) else {
                    continue
                }

                let cast = (controllerClass == os.storyboardControllerReturnType ? "" : " as! \(controllerClass)")
                output += "\n"
                output += "        static func instantiate\(SwiftRepresentationForString(string: storyboardIdentifier, capitalizeFirstLetter: true))() -> \(controllerClass) {\n"
                output += "            return self.storyboard.instantiate\(os.storyboardControllerSignatureType)(withIdentifier: \"\(storyboardIdentifier)\")\(cast)\n"
                output += "        }\n"
            }
        }
        output += "    }\n"

        return output
    }

    func processViewControllers() -> String {
        var output = String()

        for scene in self.scenes {
            if let viewController = scene.viewController {
                if let customClass = viewController.customClass {
                    output += "\n"
                    output += "//MARK: - \(customClass)\n"

                    if let segues = scene.segues?.filter({ return $0.identifier != nil }), segues.count > 0 {
                        output += "extension \(os.storyboardSegueType) {\n"
                        output += "    func selection() -> \(customClass).Segue? {\n"
                        output += "        if let identifier = self.identifier {\n"
                        output += "            return \(customClass).Segue(rawValue: identifier)\n"
                        output += "        }\n"
                        output += "        return nil\n"
                        output += "    }\n"
                        output += "}\n"
                        output += "\n"
                    }

                    if let storyboardIdentifier = viewController.storyboardIdentifier {
                        output += "protocol  \(customClass)IdentifiableProtocol: IdentifiableProtocol { }\n"
                        output += "\n"
                        output += "extension  \(customClass): \(customClass)IdentifiableProtocol { }\n"
                        output += "\n"
                        output += "extension IdentifiableProtocol where Self: \(customClass) {\n"
                        if viewController.customModule != nil {
                            output += "    var storyboardIdentifier: String? { return \"\(storyboardIdentifier)\" }\n"
                        } else {
                            output += "    public var storyboardIdentifier: String? { return \"\(storyboardIdentifier)\" }\n"
                        }
                        output += "    static var storyboardIdentifier: String? { return \"\(storyboardIdentifier)\" }\n"
                        output += "}\n"
                        output += "\n"
                    }

                    if let segues = scene.segues?.filter({ return $0.identifier != nil }), segues.count > 0 {
                        output += "extension \(customClass) { \n"
                        output += "\n"
                        output += "    enum Segue: String, CustomStringConvertible, SegueProtocol {\n"
                        for segue in segues {
                            if let identifier = segue.identifier
                            {
                                output += "        case \(SwiftRepresentationForString(string: identifier)) = \"\(identifier)\"\n"
                            }
                        }
                        output += "\n"
                        output += "        var kind: SegueKind? {\n"
                        output += "            switch (self) {\n"
                        var needDefaultSegue = false
                        for segue in segues {
                            if let identifier = segue.identifier {
                                output += "            case .\(SwiftRepresentationForString(string: identifier)):\n"
                                output += "                return SegueKind(rawValue: \"\(segue.kind)\")\n"
                            } else {
                                needDefaultSegue = true
                            }
                        }
                        if needDefaultSegue {
                            output += "            default:\n"
                            output += "                assertionFailure(\"Invalid value\")\n"
                            output += "                return nil\n"
                        }
                        output += "            }\n"
                        output += "        }\n"
                        output += "\n"
                        output += "        var destination: \(self.os.storyboardControllerReturnType).Type? {\n"
                        output += "            switch (self) {\n"
                        var needDefaultDestination = false
                        for segue in segues {
                            if let identifier = segue.identifier, let destination = segue.destination,
                                let destinationElement = searchById(id: destination)?.element,
                                let destinationClass = (destinationElement.attributes["customClass"] ?? os.controllerTypeForElementName(name: destinationElement.name))
                            {
                                output += "            case .\(SwiftRepresentationForString(string: identifier)):\n"
                                output += "                return \(destinationClass).self\n"
                            } else {
                                needDefaultDestination = true
                            }
                        }
                        if needDefaultDestination {
                            output += "            default:\n"
                            output += "                assertionFailure(\"Unknown destination\")\n"
                            output += "                return nil\n"
                        }
                        output += "            }\n"
                        output += "        }\n"
                        output += "\n"
                        output += "        var identifier: String? { return self.description } \n"
                        output += "        var description: String { return self.rawValue }\n"
                        output += "    }\n"
                        output += "\n"
                        output += "}\n"
                    }

                    if let reusables = viewController.reusables?.filter({ return $0.reuseIdentifier != nil }), reusables.count > 0 {

                        output += "extension \(customClass) { \n"
                        output += "\n"
                        output += "    enum Reusable: String, CustomStringConvertible, ReusableViewProtocol {\n"
                        for reusable in reusables {
                            if let identifier = reusable.reuseIdentifier {
                                output += "        case \(SwiftRepresentationForString(string: identifier, doNotShadow: reusable.customClass)) = \"\(identifier)\"\n"
                            }
                        }
                        output += "\n"
                        output += "        var kind: ReusableKind? {\n"
                        output += "            switch (self) {\n"
                        var needDefault = false
                        for reusable in reusables {
                            if let identifier = reusable.reuseIdentifier {
                                output += "            case .\(SwiftRepresentationForString(string: identifier, doNotShadow: reusable.customClass)):\n"
                                output += "                return ReusableKind(rawValue: \"\(reusable.kind)\")\n"
                            } else {
                                needDefault = true
                            }
                        }
                        if needDefault {
                            output += "            default:\n"
                            output += "                preconditionFailure(\"Invalid value\")\n"
                            output += "                break\n"
                        }
                        output += "            }\n"
                        output += "        }\n"
                        output += "\n"
                        output += "        var viewType: \(self.os.viewType).Type? {\n"
                        output += "            switch (self) {\n"
                        needDefault = false
                        for reusable in reusables {
                            if let identifier = reusable.reuseIdentifier, let customClass = reusable.customClass {
                                output += "            case .\(SwiftRepresentationForString(string: identifier, doNotShadow: reusable.customClass)):\n"
                                output += "                return \(customClass).self\n"
                            } else {
                                needDefault = true
                            }
                        }
                        if needDefault {
                            output += "            default:\n"
                            output += "                return nil\n"
                        }
                        output += "            }\n"
                        output += "        }\n"
                        output += "\n"
                        output += "        var storyboardIdentifier: String? { return self.description } \n"
                        output += "        var description: String { return self.rawValue }\n"
                        output += "    }\n"
                        output += "\n"
                        output += "}\n\n"
                    }
                }
            }
        }
        return output
    }
}

