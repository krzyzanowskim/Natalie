//
//  main.swift
//  Natalie
//
//  Created by Marcin Krzyzanowski on 07/08/16.
//  Copyright © 2016 Marcin Krzyzanowski. All rights reserved.
//

import Foundation

if CommandLine.arguments.count == 1 {
    print("Invalid usage. Missing path to storyboard.")
    exit(1)
}

let argument = CommandLine.arguments[1]
var filePaths: [String] = []
let storyboardSuffix = ".storyboard"
if argument.hasSuffix(storyboardSuffix) {
    filePaths = [argument]
} else if let s = findStoryboards(rootPath: argument, suffix: storyboardSuffix) {
    filePaths = s
}

let storyboardFiles = filePaths.flatMap { try? StoryboardFile(filePath: $0) }

let output = Natalie.process(storyboards: storyboardFiles)
print(output)

exit(0)
