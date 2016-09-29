//
//  ScreenOneViewController.swift
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

class ScreenOneViewController: NTLViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    #if !os(OSX)
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    #endif

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
