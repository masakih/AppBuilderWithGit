//
//  AppDelegate.swift
//  AppBuilderWithGit
//
//  Created by Hori,Masaki on 2017/08/11.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        guard checkXcode() else {
            
            let alert = NSAlert()
            
            alert.messageText = "Xcode is not found"
            alert.informativeText = "This Application require Xcode.\nYou can install Xcode with App Store.\nXcode is free."
            alert.addButton(withTitle: "Open App Store")
            alert.addButton(withTitle: "Quit")
            
            let result = alert.runModal()
            
            switch result {
                
            case NSAlertFirstButtonReturn: openAppStore()
                
            default: ()
                
            }
            
            NSApplication.shared().terminate(nil)
            return
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        
        return true
    }
    
    var xcodeURL: URL? {
        
        return NSWorkspace.shared().urlForApplication(withBundleIdentifier: "com.apple.dt.xcode")
    }
    
    private func checkXcode() -> Bool {
        
        return xcodeURL != nil
    }
    private func openAppStore() {
        
        let urlString = "macappstore://itunes.apple.com/app/xcode/id497799835"
        if let url = URL(string: urlString) {
            
            NSWorkspace.shared().open(url)
        }
        
    }
}

