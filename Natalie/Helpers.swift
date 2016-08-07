//
//  Helpers.swift
//  Natalie
//
//  Created by Marcin Krzyzanowski on 07/08/16.
//  Copyright © 2016 Marcin Krzyzanowski. All rights reserved.
//

func SwiftRepresentationForString(string: String, capitalizeFirstLetter: Bool = false, doNotShadow: String? = nil) -> String {
    var str =  string.trimAllWhitespacesAndSpecialCharacters()
    if capitalizeFirstLetter {
        str = String(str.uppercased().unicodeScalars.prefix(1) + str.unicodeScalars.suffix(str.unicodeScalars.count - 1))
    }
    if str == doNotShadow {
        str = str + "_"
    }
    return str
}
