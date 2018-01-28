//
//  AppDelegate.swift
//  AirGestures
//
//  Created by Brendon Warwick on 27/01/2018.
//  Copyright © 2018 Team Limoncello. All rights reserved.
//

import Cocoa

@NSApplicationMain class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let popover = NSPopover()
    var eventMonitor: EventMonitor?
    var button : NSStatusBarButton?
    var disabledImage : NSImage?
    var enabledImage : NSImage?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupMenuBarIcon()
        setupEventMonitor()
        GSM = GestureServiceManager()
    }
    
    func setupMenuBarIcon() {
        button = statusItem.button
        enabledImage = NSImage(named:NSImage.Name("Menu Bar Icon"))
        enabledImage?.isTemplate = true
        disabledImage = NSImage(named:NSImage.Name("Menu Bar Icon Disabled"))
        disabledImage?.isTemplate = true
        button?.image = disabledImage
        button?.action = #selector(togglePopover(_:))
        popover.contentViewController = MenuViewController.freshController()
    }
    
    func setIcon(isEnabled: Bool) {
        button?.image = isEnabled ? enabledImage : disabledImage;
    }
    
    func setupEventMonitor() {
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover(sender: event)
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
        eventMonitor?.start()
    }
    
    func closePopover(sender: Any?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
}

