//
//  Helpers.swift
//  Natalie
//
//  Created by Marcin Krzyzanowski on 07/08/16.
//  Copyright © 2016 Marcin Krzyzanowski. All rights reserved.
//

import Foundation

func findStoryboards(rootPath: String, suffix: String) -> [String]? {
    var result = Array<String>()
    let fm = FileManager.default
    if let paths = fm.subpaths(atPath: rootPath) {
        let storyboardPaths = paths.filter({ return $0.hasSuffix(suffix)})
        // result = storyboardPaths
        for p in storyboardPaths {
            result.append((rootPath as NSString).appendingPathComponent(p))
        }
    }
    return result.count > 0 ? result : nil
}

func swiftRepresentation(for string: String, capitalizeFirstLetter: Bool = false, doNotShadow: String? = nil) -> String {
    var str =  string.trimAllWhitespacesAndSpecialCharacters()
    if capitalizeFirstLetter {
        str = String(str.uppercased().unicodeScalars.prefix(1) + str.unicodeScalars.suffix(str.unicodeScalars.count - 1))
    }
    if str == doNotShadow {
        str = str + "_"
    }
    return str
}
