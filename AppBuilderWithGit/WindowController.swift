//
//  WindowController.swift
//  AppBuilderWithGit
//
//  Created by Hori,Masaki on 2017/08/12.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa


class WindowController: NSWindowController {
    
    func windowShouldClose(_ sender: Any) -> Bool {
        
        return NSApplication.appDelegate.canTerminate()
    }
}
