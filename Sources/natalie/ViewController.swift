//
//  ViewController.swift
//  Natalie
//
//  Created by Marcin Krzyzanowski on 07/08/16.
//  Copyright © 2016 Marcin Krzyzanowski. All rights reserved.
//

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
