//
//  ViewController.swift
//  NatalieExample
//
//  Created by Marcin Krzyzanowski on 15/04/15.
//  Copyright (c) 2015 Marcin Krzyżanowski. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segueIdentifier = segue.identifier {
            switch (segueIdentifier) {
            case "ScreenOneSegue":
                    if let oneViewController = segue.destinationViewController as? ScreenOneViewController {
                        oneViewController.view.backgroundColor = UIColor.yellowColor()
                    }
                break
            case "ScreenTwoSegue":
                if let twoViewController = segue.destinationViewController as? ScreenTwoViewController {
                    twoViewController.view.backgroundColor = UIColor.magentaColor()
                }
                break
            default:
                break
            }
        }
    }

    //MARK: Actions
    
    @IBAction func screen1ButtonPressed(button:UIButton) {
        self.performSegueWithIdentifier("ScreenOneSegue", sender: self)
    }
    
    @IBAction func screen22ButtonPressed(button:UIButton) {
        self.performSegueWithIdentifier("ScreenTwoSegue", sender: self)
    }

}

