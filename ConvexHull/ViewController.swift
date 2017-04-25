//
//  ViewController.swift
//  ConvexHull
//
//  Created by Ariel Rodriguez on 2/5/17.
//  Copyright © 2017 VolonBolon. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var convexHullView: ConvexHullView!
    @IBOutlet weak var stepper: NSStepper!
    @IBOutlet weak var numberOfDotsLabel: NSTextField!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNumberOfDots()
    }

    @IBAction func regenerate(_ sender: Any) {
        self.convexHullView.refresh()
    }
    
    @IBAction func numberOfDotsChanged(_ sender: NSStepper) {
        self.setupNumberOfDots()
    }

}

extension ViewController {
    fileprivate func setupNumberOfDots() {
        let numberOfDots = self.stepper.integerValue
        self.convexHullView.numberOfDots = numberOfDots
        self.numberOfDotsLabel.stringValue = "\(numberOfDots)"
    }
}

