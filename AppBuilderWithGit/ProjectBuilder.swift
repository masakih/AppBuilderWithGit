//
//  ProjectBuilder.swift
//  AppBuilderWithGit
//
//  Created by Hori,Masaki on 2017/08/11.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa


enum ProjectBuilderError: Error {
    
    case commandNotFound
    
    case commandFail
    
    case canNotCreateBuildDir
    
    case other(String)
}


final class ProjectBuilder {
        
    let info: BuildInfo
    
    init?(_ url: URL) {
        
        guard let info = BuildInfo(projectURL: url) else {
            
            return nil
        }
        
        self.info = info
    }
    
    var productURL: URL { return info.productURL }
    
    func build() throws {
        
        let builderURL = URL(fileURLWithPath: "Contents/Developer/usr/bin/xcodebuild",
                         relativeTo: NSApplication.appDelegate.xcodeURL)
        guard let xcodebuildReachable = try? builderURL.checkResourceIsReachable(),
            xcodebuildReachable else {
                
                throw ProjectBuilderError.commandNotFound
        }
        
        guard let reachable = try? info.projectURL.checkResourceIsReachable(),
            reachable else {
                
                throw ProjectBuilderError.other("URL is Invalid.")
        }
        
        let xcodebuild = Process() <<< ExcutableURL(url: builderURL)
            <<< info.arguments
            <<< info.projectURL
        
        xcodebuild >>> { stdout, stderr in
            
            let log = LogStocker("xcodebuild.log")
            log?.write(stdout.data)
            log?.write(stderr.data)
        }
        
        xcodebuild.waitUntilExit()
        
        guard xcodebuild.terminationStatus == 0 else {
            
            throw ProjectBuilderError.commandFail
        }
    }
}
