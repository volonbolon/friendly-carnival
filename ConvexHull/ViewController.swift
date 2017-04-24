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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func regenerate(_ sender: Any) {
        self.convexHullView.refresh()
    }

}

