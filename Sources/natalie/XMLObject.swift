//
//  XMLObject.swift
//  Natalie
//
//  Created by Marcin Krzyzanowski on 07/08/16.
//  Copyright © 2016 Marcin Krzyzanowski. All rights reserved.
//

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
