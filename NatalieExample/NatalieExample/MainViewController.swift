//
//  ViewController.swift
//  NatalieExample
//
//  Created by Marcin Krzyzanowski on 15/04/15.
//  Copyright (c) 2015 Marcin Krzyżanowski. All rights reserved.
//

#if os(OSX)
    import AppKit
    typealias NTLViewController = NSViewController
    typealias NTLButton = NSButton
    typealias NTLStoryboardSegue = NSStoryboardSegue
    typealias NTLColor = NSColor
#else
    import UIKit
    typealias NTLViewController = UIViewController
    typealias NTLButton = UIButton
    typealias NTLStoryboardSegue = UIStoryboardSegue
    typealias NTLColor = UIColor
#endif

class MainViewController: NTLViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: Navigation

    override func prepare(for segue: NTLStoryboardSegue, sender: Any?) {
        if segue == MainViewController.Segue.screenOneSegue, let oneViewController = segue.destination as? ScreenOneViewController {
            if #available(OSX 10.13, iOS 11.0, tvOS 11.0, *) {
                oneViewController.view.backgroundColor = NTLColor.Screen1 ?? .orange
            } else {
                oneViewController.view.backgroundColor = .orange
            }
        } else if segue == MainViewController.Segue.screenOneSegueButton, let oneViewController = segue.destination as? ScreenOneViewController {
                oneViewController.view.backgroundColor = .brown
        } else if segue == MainViewController.Segue.screenTwoSegue, let twoViewController = segue.destination as? ScreenTwoViewController {
            if #available(OSX 10.13, iOS 11.0, tvOS 11.0, *) {
                twoViewController.view.backgroundColor = NTLColor.Screen2 ?? .blue
            } else {
                twoViewController.view.backgroundColor = .blue
            }
        } else if segue == MainViewController.Segue.sceneOneGestureRecognizerSegue, let oneViewController = segue.destination as? ScreenOneViewController {
            oneViewController.view.backgroundColor = .green
        }
    }

    // MARK: Actions

    @IBAction func screen1ButtonPressed(_ button: NTLButton) {
        self.perform(segue: MainViewController.Segue.screenOneSegue)
    }

    @IBAction func screen22ButtonPressed(_ button: NTLButton) {
        self.perform(segue: MainViewController.Segue.screenTwoSegue)
    }

}

#if os(OSX)
    extension NSStoryboardSegue {
        open var source: Any { return sourceController }
        open var destination: Any { return destinationController }
    }
    extension NSView {
       @IBInspectable open var backgroundColor: NSColor {
            get {
                if let color: CGColor = self.layer?.backgroundColor {
                    return NSColor(cgColor: color)!
                }
                return NSColor.clear
            }
            set(newBG) {
                self.wantsLayer = true
                if let layer = self.layer {
                    layer.backgroundColor = newBG.cgColor
                }
            }
        }

    }
#endif
