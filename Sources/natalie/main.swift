//
//  main.swift
//  Natalie
//
//  Created by Marcin Krzyzanowski on 07/08/16.
//  Copyright © 2016 Marcin Krzyzanowski. All rights reserved.
//

import Foundation

func printUsage() {
    print("Usage:")
    print("natalie <storyboard-path or directory>")
}

if CommandLine.arguments.count == 1 {
    printUsage()
    exit(1)
}

var filePaths: [String] = []
let storyboardSuffix = ".storyboard"

for arg in CommandLine.arguments {
    if arg == "--help" {
        printUsage()
        exit(0)
    } else if arg.hasSuffix(storyboardSuffix) {
        filePaths.append(arg)
    } else if let s = findStoryboards(rootPath: arg, suffix: storyboardSuffix) {
        filePaths.append(contentsOf: s)
    }
}

let storyboardFiles = filePaths.flatMap { try? StoryboardFile(filePath: $0) }

let output = Natalie.process(storyboards: storyboardFiles)
print(output)

exit(0)
