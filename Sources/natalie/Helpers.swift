//
//  Helpers.swift
//  Natalie
//
//  Created by Marcin Krzyzanowski on 07/08/16.
//  Copyright © 2016 Marcin Krzyzanowski. All rights reserved.
//

import Foundation

func findStoryboards(rootPath: String, suffix: String) -> [String]? {
    var result = [String]()
    let fm = FileManager.default
    if let paths = fm.subpaths(atPath: rootPath) {
        let storyboardPaths = paths.filter({ return $0.hasSuffix(suffix)})
        // result = storyboardPaths
        for p in storyboardPaths {
            result.append((rootPath as NSString).appendingPathComponent(p))
        }
    }
    return result.isEmpty ? nil : result
}

enum FirstLetterFormat {
    case none
    case capitalize
    case lowercase

    func format(_ str: String) -> String {
        switch self {
        case .none:
            return str
        case .capitalize:
            return String(str.uppercased().unicodeScalars.prefix(1) + str.unicodeScalars.suffix(str.unicodeScalars.count - 1))
        case .lowercase:
            return String(str.lowercased().unicodeScalars.prefix(1) + str.unicodeScalars.suffix(str.unicodeScalars.count - 1))
        }
    }
}

func swiftRepresentation(for string: String, firstLetter: FirstLetterFormat = .none, doNotShadow: String? = nil) -> String {
    var str = string.trimAllWhitespacesAndSpecialCharacters()
    str = firstLetter.format(str)
    if str == doNotShadow {
        str += "_"
    }
    return str
}
