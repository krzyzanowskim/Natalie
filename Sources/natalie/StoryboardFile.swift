//
//  StoryboardFile.swift
//  Natalie
//
//  Created by Marcin Krzyzanowski on 07/08/16.
//  Copyright © 2016 Marcin Krzyzanowski. All rights reserved.
//

import Foundation

class StoryboardFile {

    let data: Data
    let storyboardName: String
    let storyboard: Storyboard

    init(filePath: String) throws {
        let url = URL(fileURLWithPath: filePath)
        self.data = try Data(contentsOf: url)
        self.storyboardName = ((filePath as NSString).lastPathComponent as NSString).deletingPathExtension
        self.storyboard = Storyboard(xml:SWXMLHash.parse(self.data))
    }
}
