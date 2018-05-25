//
//  BuildInfo.swift
//  AppBuilderWithGit
//
//  Created by Hori,Masaki on 2017/08/12.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

struct BuildInfo {
    
    private enum ProjectType {
        
        case xcodeproj
        
        case xcworkspace
        
        init?(projectFileURL: URL) {
            
            switch projectFileURL.pathExtension {
                
            case "xcodeproj": self = .xcodeproj
                
            case "xcworkspace": self = .xcworkspace
                
            default: return nil
            }
        }
    }
    
    private static let buildDir = "Build"
    
    let projectURL: URL
    let productURL: URL
    let buildURL: URL
    
    let arguments: [String]
    
    init?(projectURL: URL) {
        
        guard let projectFileURL = find(in: projectURL) else { return nil }
        
        self.projectURL = projectURL
        
        guard let type = ProjectType(projectFileURL: projectFileURL) else { return nil }
        
        switch type {
            
        case .xcworkspace:
            self.buildURL = ApplicationDirecrories.support.appendingPathComponent(BuildInfo.buildDir)
            self.productURL = buildURL.appendingPathComponent("Build/Products/Release")
            self.arguments = [
                "-workspace",
                projectFileURL.lastPathComponent,
                "-scheme",
                projectFileURL.deletingPathExtension().lastPathComponent,
                "-configuration",
                "Release",
                "-derivedDataPath",
                buildURL.path
            ]
            
        case .xcodeproj:
            self.buildURL = projectURL.appendingPathComponent("build")
            self.productURL = buildURL.appendingPathComponent("Release")
            self.arguments = ["-configuration", "Release"]
        }
    }
}
