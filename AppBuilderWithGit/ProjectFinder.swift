//
//  ProjectFinder.swift
//  AppBuilderWithGit
//
//  Created by Hori,Masaki on 2017/08/11.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation


final class ProjectFinder {
    
    static func find(in url: URL, depth: Int = 1) -> URL? {
        
        guard depth != 0 else { return nil }
        
        guard let contents = try? FileManager.default.contentsOfDirectory(at: url,
                                                                          includingPropertiesForKeys: [.isDirectoryKey])
            else {
                return nil
        }
        
        if let url = contents.lazy.filter({ $0.pathExtension == "xcworkspace" }).first {
            
            return url
        }
        
        if let url = contents.lazy.filter({ $0.pathExtension == "xcodeproj" }).first {
            
            return url
        }
        
        
        func isDir(_ url: URL) -> Bool {
            
            return (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
        }
        
        return contents.lazy
            .filter(isDir)
            .flatMap { find(in: $0, depth: depth - 1) }
            .first
        
    }
}
