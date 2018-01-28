//
//  GestureServiceManager.swift
//  AirGestures
//
//  Created by Charlie Harding on 27/01/2018.
//  Copyright © 2018 Team Limoncello. All rights reserved.
//

import Cocoa

class GestureServiceManager : NSObject {
    let ptManager = PTManager.instance
    
    override init() {
        super.init()
        
        // Setup the PTManager
        ptManager.delegate = self
        ptManager.connect(portNumber: PORT_NUMBER)
        
        print("Initialized Gesture Service manager on port \(PORT_NUMBER)")
    }
    
    func click() {
        if let clickScriptPath = Bundle.main.path(forResource: "click", ofType: "applescript") {
            do {
                let clickScriptContents = try String(contentsOfFile: clickScriptPath)
                print(clickScriptContents)
                
                var error: NSDictionary?
                if let csc = NSAppleScript(source: clickScriptContents) {
                    let _: NSAppleEventDescriptor = csc.executeAndReturnError(&error)
                    if (error != nil) {
                        print("error: \(String(describing: error))")
                    } else {
                        print("Executed click script successfully")
                    }
                }
            } catch {
                print("Contents of applescript could not be loaded")
            }
        } else {
            print("Click script could not be found!")
        }
    }
}

extension GestureServiceManager: PTManagerDelegate {
    
    func peertalk(shouldAcceptDataOfType type: UInt32) -> Bool {
        return true
    }
    
    func peertalk(didReceiveData data: Data) {
        let num = data.convert() as! String
        print("Recieved \(num)")
    }
    
    func peertalk(didChangeConnection connected: Bool) {
        print("Connection: \(connected)")
        print(connected ? "Connected" : "Disconnected")
    }
}

var GSM: GestureServiceManager!
