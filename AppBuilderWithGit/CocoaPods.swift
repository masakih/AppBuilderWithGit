//
//  CocoaPods.swift
//  AppBuilderWithGit
//
//  Created by Hori,Masaki on 2018/04/08.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Foundation

enum CocoaPodsError: Error {
    
    case commandNotFound
    
    case commandFail
}

final class CocoaPods {
    
    let baseURL: URL
    
    init(_ url: URL) {
        
        self.baseURL = url
    }
    
    private var podfileURL: URL? {
        
        return findFile(pattern: "^Podfile$", in: baseURL, depth: 2)
    }
    
    private var podURL: URL? {
        
        return commandPath("pod")
    }
    
    func checkCocoaPods() -> Bool {
        
        guard podfileURL != nil else {
            
            return false
        }
        
        guard podURL != nil else {
            
            return false
        }
        
        return true
    }
    
    func execute() throws {
        
        guard let podfile = podfileURL else {
            
            return
        }
        
        guard let podURL = podURL else {
            
            throw CarthageError.commandNotFound
        }
        
        let pod = Process() <<< podURL.path <<< ["install"]
        pod.currentDirectoryPath = podfile.deletingLastPathComponent().path
        
        pod >>> { output, error in
            
            let log = LogStocker("cocoapods.log")
            log?.write(output.data)
            log?.write(error.data)
        }
        pod.waitUntilExit()
        
        if pod.terminationStatus != 0 {
            
            throw CarthageError.commandFail
        }
    }
}

