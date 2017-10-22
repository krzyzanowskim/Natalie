//
//  Color.swift
//  natalie
//
//  Created by phimage on 22/10/2017.
//  Copyright © 2017 Marcin Krzyzanowski. All rights reserved.
//

class Color: XMLObject {

    enum Catalog: String {
        case system = "System"
    }

    enum ColorSpace: String {
        case catalog
        case custom
    }

    enum CustomColorSpace: String {
        case sRGB
    }

    typealias Component = Double

    lazy var key: String? = self.xml.element?.attribute(by: "key")?.text
    lazy var assetName: String? = self.xml.element?.attribute(by: "name")?.text
    lazy var catalog: Catalog? = self.xml.element?.attribute(by: "catalog")?.raw(Catalog.self)
    lazy var colorSpace: ColorSpace? = self.xml.element?.attribute(by: "colorSpace")?.raw(ColorSpace.self)
    lazy var customColorSpace: CustomColorSpace? = self.xml.element?.attribute(by: "customColorSpace")?.raw(CustomColorSpace.self)

    lazy var red: Component? = self.xml.element?.attribute(by: "red")?.colorComponent
    lazy var green: Component? = self.xml.element?.attribute(by: "green")?.colorComponent
    lazy var blue: Component? = self.xml.element?.attribute(by: "blue")?.colorComponent
    lazy var alpha: Component? = self.xml.element?.attribute(by: "alpha")?.colorComponent

    lazy var components: (red: Component, blue: Component, green: Component, alpha: Component)? = {
        guard let red = red, let blue = blue, let green = green, let alpha = alpha else {
            return nil
        }
        return (red, green, blue, alpha)
    }()

    override init(xml: XMLIndexer) {
        super.init(xml: xml)
    }

}

extension XMLAttribute {
    var colorComponent: Color.Component? {
        return Color.Component(self.text)
    }
    func raw<R>(_ typeR: R.Type) -> R? where R: RawRepresentable, R.RawValue == String {
        return typeR.init(rawValue: self.text)
    }
}
