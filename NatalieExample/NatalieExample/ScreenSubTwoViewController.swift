//
//  ScreenSubTwoViewController.swift
//  NatalieExample
//
//  Created by Marcin Krzyzanowski on 15/04/15.
//  Copyright (c) 2015 Marcin Krzyżanowski. All rights reserved.
//

#if os(OSX)
    import AppKit
#else
    import UIKit
#endif

class ScreenSubTwoViewController: ScreenTwoViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

#if os(iOS)
extension ScreenSubTwoViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(reusable: ScreenSubTwoViewController.Reusable.MyCell, for: indexPath)!
        cell.textLabel?.text = "\((indexPath as NSIndexPath).row)"
        return cell
    }
}
#endif
