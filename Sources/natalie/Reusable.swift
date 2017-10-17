//
//  Reusable.swift
//  Natalie
//
//  Created by Marcin Krzyzanowski on 07/08/16.
//  Copyright © 2016 Marcin Krzyzanowski. All rights reserved.
//

class Reusable: XMLObject {

    let kind: String
    lazy var reuseIdentifier: String? = self.xml.element?.attribute(by: "reuseIdentifier")?.text
    lazy var customClass: String? = self.xml.element?.attribute(by: "customClass")?.text

    override init(xml: XMLIndexer) {
        kind = xml.element!.name
        super.init(xml: xml)
    }

}
