//
//  Carthage.swift
//  AppBuilderWithGit
//
//  Created by Hori,Masaki on 2018/04/08.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Foundation

final class Carthage {
    
    let baseURL: URL
    
    init(_ url: URL) {
        
        self.baseURL = url
    }
    
    private var cartfileURL: URL? {
        
        return findFile(pattern: "Cartfile$", in: baseURL)
    }
    
    private var carthageURL: URL? {
        
        return commandPath("carthage")
    }
    
    func checkCarthage() -> Bool {
        
        guard cartfileURL != nil else {
            
            return false
        }
        
        guard carthageURL != nil else {
            
            return false
        }
        
        return true
    }
    
    func execute() {
        
        guard let cartfile = cartfileURL else {
            
            return
        }
        
        guard let carthageURL = carthageURL else {
            
            return
        }
        
        let log = LogStocker("carthage.log")
        
        let carthage = Process() <<< carthageURL.path <<< ["update"]
        carthage.currentDirectoryPath = cartfile.deletingLastPathComponent().path
        
        carthage >>> { output, error in
            log?.write(output.data)
            log?.write(error.data)
        }
        carthage.waitUntilExit()
        
        if carthage.terminationStatus != 0 {
            
            log?.write("Carthage error exit with status \(carthage.terminationStatus)")
        }
    }
}
