//
//  MenuViewController.swift
//  AirGestures
//
//  Created by Charlie Harding on 27/01/2018.
//  Copyright © 2018 Team Limoncello. All rights reserved.
//

import Cocoa

class MenuViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}

extension MenuViewController {
    static func freshController() -> MenuViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("MenuViewController")
        
        guard let viewController = storyboard.instantiateController(withIdentifier: identifier) as? MenuViewController
        else {
            fatalError("Cannot find MenuViewController.")
        }
        return viewController
    }
}
