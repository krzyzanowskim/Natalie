//
//  ScreenTwoViewController.swift
//  NatalieExample
//
//  Created by Marcin Krzyzanowski on 15/04/15.
//  Copyright (c) 2015 Marcin Krzyżanowski. All rights reserved.
//

#if os(OSX)
    import AppKit
    typealias NTLTableView = NSTableView
#else
    import UIKit
    typealias NTLTableView = UITableView
#endif

class ScreenTwoViewController: NTLViewController {
    @IBOutlet var tableView: NTLTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

#if os(iOS)
extension ScreenTwoViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(reusable: Reusable.MyCell, for: indexPath)!
        cell.textLabel?.text = "\((indexPath as NSIndexPath).row)"
        return cell
    }
}
#endif
