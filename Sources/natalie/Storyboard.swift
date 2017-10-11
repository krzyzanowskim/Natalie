//
//  Storyboard.swift
//  Natalie
//
//  Created by Marcin Krzyzanowski on 07/08/16.
//  Copyright © 2016 Marcin Krzyzanowski. All rights reserved.
//

class Storyboard: XMLObject {

    let version: String
    lazy var os: OS = {
        guard let targetRuntime = self.xml["document"].element?.attribute(by: "targetRuntime")?.text else {
            return OS.iOS
        }

        return OS(targetRuntime: targetRuntime)
    }()

    lazy var initialViewControllerClass: String? = {
        if let initialViewControllerId = self.xml["document"].element?.attribute(by: "initialViewController")?.text,
            let xmlVC = self.searchById(id: initialViewControllerId) {
            let vc = ViewController(xml: xmlVC)
            if let customClassName = vc.customClass {
                return customClassName
            }

            if let controllerType = self.os.controllerType(for: vc.name) {
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

    lazy var customModules: Set<String> = Set(self.scenes.filter { $0.customModule != nil && $0.customModuleProvider == nil }.map { $0.customModule! })

    override init(xml: XMLIndexer) {
        self.version = xml["document"].element!.attribute(by: "version")!.text
        super.init(xml: xml)
    }

}
