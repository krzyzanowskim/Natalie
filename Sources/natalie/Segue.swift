//
//  Segue.swift
//  Natalie
//
//  Created by Marcin Krzyzanowski on 07/08/16.
//  Copyright © 2016 Marcin Krzyzanowski. All rights reserved.
//

class Segue: XMLObject {

    let kind: String
    let identifier: String?
    lazy var destination: String? = self.xml.element?.attributes["destination"]

    override init(xml: XMLIndexer) {
        self.kind = xml.element!.attributes["kind"]!
        if let id = xml.element?.attributes["identifier"], !id.characters.isEmpty {
            self.identifier = id
        } else {
            self.identifier = nil
        }
        super.init(xml: xml)
    }

}
