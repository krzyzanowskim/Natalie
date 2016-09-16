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
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue == MainViewController.Segue.ScreenOneSegue, let oneViewController = segue.destination as? ScreenOneViewController {
            oneViewController.view.backgroundColor = UIColor.yellow
        } else if segue == MainViewController.Segue.ScreenOneSegueButton, let oneViewController = segue.destination as? ScreenOneViewController {
            oneViewController.view.backgroundColor = UIColor.brown
        } else if segue == MainViewController.Segue.ScreenTwoSegue, let twoViewController = segue.destination as? ScreenTwoViewController {
            twoViewController.view.backgroundColor = UIColor.magenta
        } else if segue == MainViewController.Segue.SceneOneGestureRecognizerSegue, let oneViewController = segue.destination as? ScreenOneViewController {
            oneViewController.view.backgroundColor = UIColor.green
        }
    }

    //MARK: Actions
    
    @IBAction func screen1ButtonPressed(_ button:UIButton) {
        self.perform(segue: MainViewController.Segue.ScreenOneSegue)
    }

    @IBAction func screen22ButtonPressed(_ button:UIButton) {
        self.performSegue(withIdentifier: MainViewController.Segue.ScreenTwoSegue.rawValue, sender: nil)
    }

}

