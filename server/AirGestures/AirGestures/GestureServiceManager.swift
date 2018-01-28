//
//  GestureServiceManager.swift
//  AirGestures
//
//  Created by Charlie Harding on 27/01/2018.
//  Copyright © 2018 Team Limoncello. All rights reserved.
//

import Cocoa

enum AppState {
    case SYSTEM
    case MUSIC
}

class GestureServiceManager : NSObject {
    let ptManager = PTManager.instance
    var state: AppState? {
        didSet {
            print("Current state: \(String(describing: state))")
        }
    }
    
    override init() {
        super.init()
        // Set state to default to system
        state = .SYSTEM
        // Setup the PTManager
        ptManager.delegate = self
        ptManager.connect(portNumber: PORT_NUMBER)
        
        print("Initialized Gesture Service manager on port \(PORT_NUMBER)")
    }
    
    func click() {
        if state == .SYSTEM {
            sysClick()
        } else if state == .MUSIC {
            musicClick()
        }
    }
    
    func sysClick(){
        print("Doing sys click")
        if let clickScriptPath = Bundle.main.path(forResource: "click", ofType: "applescript") {
            do {
                let clickScriptContents = try String(contentsOfFile: clickScriptPath)
                
                var error: NSDictionary?
                if let csc = NSAppleScript(source: clickScriptContents) {
                    let _: NSAppleEventDescriptor = csc.executeAndReturnError(&error)
                    if (error != nil) {
                        print("error: \(String(describing: error))")
                    } else {
                        print("Executed sys click script successfully")
                    }
                }
            } catch {
                print("Contents of applescript could not be loaded")
            }
        } else {
            print("Click script could not be found!")
        }
    }
    
    func musicClick(){
        print("Doing music click")
        if let clickScriptPath = Bundle.main.path(forResource: "iTunes-Play", ofType: "scpt") {
            do {
                let clickScriptContents = try String(contentsOfFile: clickScriptPath)
                
                var error: NSDictionary?
                if let csc = NSAppleScript(source: clickScriptContents) {
                    let _: NSAppleEventDescriptor = csc.executeAndReturnError(&error)
                    if (error != nil) {
                        print("error: \(String(describing: error))")
                    } else {
                        print("Executed music click script successfully")
                    }
                }
            } catch {
                print("Contents of applescript could not be loaded")
            }
        } else {
            print("Click script could not be found!")
        }
    }
    
    func process(gesture: Gesture) {
        switch gesture {
        case .oneFinger:
            state = .SYSTEM
            break
        case .twoFingers:
            state = .MUSIC
            break
        case .fist:
            click()
            break
        case .fiveFingers:
            print("Five fingers")
            break
        default:
            print("Do nothing")
        }
    }
}

extension GestureServiceManager: PTManagerDelegate {
    
    func peertalk(shouldAcceptDataOfType type: UInt32) -> Bool {
        return true
    }
    
    func peertalk(didReceiveData data: Data) {
        let num = data.convert() as! String
        let gest = Gesture(rawValue: num)
        process(gesture: gest ?? .none)
    }
    
    func peertalk(didChangeConnection connected: Bool) {
        print("Connection: \(connected)")
        print(connected ? "Connected" : "Disconnected")
    }
}

var GSM: GestureServiceManager!
