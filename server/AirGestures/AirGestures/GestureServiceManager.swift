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
    var state: AppState?
    
    // For music state, set to playing or paused
    var MusicPlaying = false
    
    override init() {
        super.init()
        // Set state to default to system
        state = .SYSTEM
        // Setup the PTManager
        ptManager.delegate = self
        ptManager.connect(portNumber: PORT_NUMBER)
        
        print("Initialized Gesture Service manager on port \(PORT_NUMBER)")
        
        musicClick()
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
        let path = Bundle.main.path(forResource: "cliclick", ofType: "")
        let arguments = ["c:+0,+0"]
        
        let task = Process.launchedProcess(launchPath: path!, arguments: arguments)
        task.waitUntilExit()
    }
    
    func musicClick(){
        print("Doing music click")
        MusicPlaying = !MusicPlaying
        let myAppleScript = MusicPlaying ? "tell application \"iTunes\" to play" : "tell application \"iTunes\" to pause"
        executeScript(scr: myAppleScript)
    }
    
    func swipeRight() {
        let myAppleScript = "tell application \"System Events\"\nkey code 124 using control down -- control-right\nend"
        executeScript(scr: myAppleScript)
    }
    
    func swipeLeft() {
        let myAppleScript = "tell application \"System Events\"\nkey code 123 using control down -- control-left\nend"
        executeScript(scr: myAppleScript)
    }
    
    func executeScript(scr: String) {
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: scr) {
            if let output: NSAppleEventDescriptor = scriptObject.executeAndReturnError(
                &error) {
                if let out = output.stringValue {
                    print(out)
                }
            } else if (error != nil) {
                print("error: \(String(describing: error))")
            }
        }
    }
    
    func process(gesture: Gesture) {
        switch gesture {
        case .oneFinger:
            print("Set state to system")
            state = .SYSTEM
            break
        case .twoFingers:
            print("Set state to music")
            state = .MUSIC
            break
        case .fist:
            click()
            break
        case .fiveFingers:
            swipeRight()
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
