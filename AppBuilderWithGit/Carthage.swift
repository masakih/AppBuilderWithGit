//
//  Carthage.swift
//  AppBuilderWithGit
//
//  Created by Hori,Masaki on 2018/04/08.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Foundation

enum CarthageError: Error {
    
    case commandNotFound
    
    case commandFail
}

final class Carthage {
    
    let baseURL: URL
    
    init(_ url: URL) {
        
        self.baseURL = url
    }
    
    private var cartfileURL: URL? {
        
        return findFile(pattern: "^Cartfile$", in: baseURL, depth: 2)
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
    
    func execute() throws {
        
        guard let cartfile = cartfileURL else {
            
            return
        }
        
        guard let carthageURL = carthageURL else {
            
            throw CarthageError.commandNotFound
        }
        
        let carthage = Process() <<< ExcutableURL(url: carthageURL)
            <<< ["bootstrap"]
            <<< cartfile.deletingLastPathComponent()
        
        carthage >>> { output, error in
            
            let log = LogStocker("carthage.log")
            log?.write(output.data)
            log?.write(error.data)
        }
        carthage.waitUntilExit()
        
        if carthage.terminationStatus != 0 {
            
            throw CarthageError.commandFail
        }
    }
}
