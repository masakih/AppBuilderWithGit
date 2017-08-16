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
        
        guard let info = BuildInfo(projectURL: url) else { return nil }
        
        self.info = info
        
    }
    
    var productURL: URL { return info.productURL }
    
    func build() throws {
        
        let xcodeURL = NSApplication.appDelegate.xcodeURL
        guard let builderURL = xcodeURL?.appendingPathComponent("/Contents/Developer/usr/bin/xcodebuild") else {
            
            throw ProjectBuilderError.commandNotFound
        }
        
        guard let reachable = try? info.projectURL.checkResourceIsReachable(),
            reachable else {
                
                throw ProjectBuilderError.other("URL is Invalid.")
        }
        
        let xcodebuild = Process()
        xcodebuild.launchPath = builderURL.path
        xcodebuild.arguments = info.arguments
        xcodebuild.currentDirectoryPath = info.projectURL.path
        
        let pipe = Pipe()
        xcodebuild.standardOutput = pipe
        xcodebuild.standardError = pipe
        let log = LogStocker("xcodebuild.log")
        log?.read(pipe.fileHandleForReading)
        
        xcodebuild.launch()
        xcodebuild.waitUntilExit()
        
        guard xcodebuild.terminationStatus == 0
            else {
                
                throw ProjectBuilderError.commandFail
        }
    }

    
}
