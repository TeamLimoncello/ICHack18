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
    }
    
    func click() {
        if state == .SYSTEM {
            pressEnter()
        } else if state == .MUSIC {
            musicClick()
        }
    }
    
    func pressEnter(){
//        print("Doing sys click")
//        let path = Bundle.main.path(forResource: "cliclick", ofType: "")
//        let arguments = ["c:+0,+0"]
//
//        let task = Process.launchedProcess(launchPath: path!, arguments: arguments)
//        task.waitUntilExit()
        let myAppleScript = "tell application \"System Events\"\nkey code 76 -- enter\nend"
        executeScript(scr: myAppleScript)
    }
    
    func musicClick(){
        print("Doing music click")
        MusicPlaying = !MusicPlaying
        let myAppleScript = "tell application \"iTunes\" to \(MusicPlaying ? "play" : "pause")"
        executeScript(scr: myAppleScript)
    }
    
    func nextSong(){
        print("Next song")
        let myAppleScript = "tell application \"iTunes\" to play next track"
        executeScript(scr: myAppleScript)
    }
    
    func previousSong(){
        print("Previous song")
        let myAppleScript = "tell application \"iTunes\" to play previous track"
        executeScript(scr: myAppleScript)
    }
    
    func swipeRight() {
        let myAppleScript = "tell application \"System Events\"\nkey code 124 -- right\nend"
        executeScript(scr: myAppleScript)
    }
    
    func swipeLeft() {
        let myAppleScript = "tell application \"System Events\"\nkey code 123 -- left\nend"
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
    
    func switchState() {
        if state == .SYSTEM {
            state = .MUSIC
        } else {
            state = .SYSTEM
        }
    }
    
    func process(gesture: Gesture, layer: Layer) {
        if gesture == .ok {
            print("Set state to system")
            if state == .SYSTEM {
                pressEnter()
            } else {
                musicClick()
            }
        } else if gesture == .twoFingers && layer == .Up {
            print("Going forward")
            if state == .SYSTEM {
                swipeRight()
            } else {
                
            }
        } else if gesture == .twoFingers && layer == .Down {
            print("Going backward")
            if state == .SYSTEM {
                swipeLeft()
            } else {
                
            }
        } else if gesture == .fiveFingers {
            switchState()
        } else {
            print("Do nothing")
        }
    }
}

extension GestureServiceManager: PTManagerDelegate {
    
    func peertalk(shouldAcceptDataOfType type: UInt32) -> Bool {
        return true
    }
    
    func peertalk(didReceiveData data: Data) {
        // Will be "gesture,layer"
        let payload = data.convert() as! String

        let gest = payload.split(separator: ",")
        let gesture = Gesture(rawValue: String(gest[0]))
        let layer = Layer(rawValue: String(gest[1]))
        
        process(gesture: gesture ?? .none, layer: layer!)
    }
    
    func peertalk(didChangeConnection connected: Bool) {
        print("Connection: \(connected)")
        print(connected ? "Connected" : "Disconnected")
    }
}

var GSM: GestureServiceManager!
