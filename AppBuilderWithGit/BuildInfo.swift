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
            self.buildURL = URL(fileURLWithPath: BuildInfo.buildDir, relativeTo: ApplicationDirecrories.support)
            self.productURL = URL(fileURLWithPath: "Build/Products/Release", relativeTo: buildURL)
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
            self.buildURL = URL(fileURLWithPath: "build", relativeTo: projectURL)
            self.productURL = URL(fileURLWithPath: "Release", relativeTo: buildURL)
            self.arguments = ["-configuration", "Release"]
        }
    }
}
