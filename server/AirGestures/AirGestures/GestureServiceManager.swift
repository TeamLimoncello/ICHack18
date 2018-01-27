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
    }
}


extension GestureServiceManager: PTManagerDelegate {
    
    func peertalk(shouldAcceptDataOfType type: UInt32) -> Bool {
        return true
    }
    
    func peertalk(didReceiveData data: Data, ofType type: UInt32) {
        if type == PTType.number.rawValue {
            let num = data.convert() as! Int
            print("Recieved \(num)")
        } else if type == PTType.image.rawValue {
            let image = NSImage(data: data)
            print("Recieved image")
        }
    }
    
    func peertalk(didChangeConnection connected: Bool) {
        print("Connection: \(connected)")
        print(connected ? "Connected" : "Disconnected")
    }
    
}
