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
    }
    
    //MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue == MainViewController.Segue.ScreenOneSegue, let oneViewController = segue.destinationViewController as? ScreenOneViewController {
            oneViewController.view.backgroundColor = UIColor.yellowColor()
        } else if segue == MainViewController.Segue.ScreenOneSegueButton, let oneViewController = segue.destinationViewController as? ScreenOneViewController {
            oneViewController.view.backgroundColor = UIColor.brownColor()
        } else if segue == MainViewController.Segue.ScreenTwoSegue, let twoViewController = segue.destinationViewController as? ScreenTwoViewController {
            twoViewController.view.backgroundColor = UIColor.magentaColor()
        } else if segue == MainViewController.Segue.SceneOneGestureRecognizerSegue, let oneViewController = segue.destinationViewController as? ScreenOneViewController {
            oneViewController.view.backgroundColor = UIColor.greenColor()
        }
    }

    //MARK: Actions
    
    @IBAction func screen1ButtonPressed(button:UIButton) {
        self.performSegue(MainViewController.Segue.ScreenOneSegue, sender: nil)
    }

    @IBAction func screen22ButtonPressed(button:UIButton) {
        self.performSegue(MainViewController.Segue.ScreenTwoSegue, sender: nil)
    }

}

