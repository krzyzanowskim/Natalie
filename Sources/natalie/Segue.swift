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
    lazy var destination: String? = self.xml.element?.attribute(by: "destination")?.text

    override init(xml: XMLIndexer) {
        self.kind = xml.element!.attribute(by: "kind")!.text
        if let id = xml.element?.attribute(by: "identifier")?.text, !id.isEmpty {
            self.identifier = id
        } else {
            self.identifier = nil
        }
        super.init(xml: xml)
    }

}
