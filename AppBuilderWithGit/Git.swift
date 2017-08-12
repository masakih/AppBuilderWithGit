//
//  Git.swift
//  AppBuilderWithGit
//
//  Created by Hori,Masaki on 2017/08/11.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa


enum GitError: Error {
    
    case none
    
    case gitError(Int32, String)
    
    case other(String)
}

final class Git {
    
    let url: URL
    
    var repositoryName: String { return repositoryName(for: url) }
    
    var repository: URL {
        
        return ApplicationDirecrories.support.appendingPathComponent(repositoryName)
    }
    
    init(_ url: URL) {
        
        self.url = url
    }
    
    // Block current thread.
    func excute(completeHandler: ((GitError) -> ())? = nil) {
        
        do {
            
            try clone()
            
            try submoduleUpdate(shuldInit: true)
            
            completeHandler?(GitError.none)
            
            return
            
        } catch {
            
            guard let e = error as? GitError else {
                
                completeHandler?(GitError.other("Unknown Error: \(error)"))
                return
            }
            
            switch e {
                
            case let .gitError(stat, _) where stat == 128:
                tryPull(completeHandler: completeHandler)
                
            default:
                completeHandler?(e)
            }
            
        }
        
    }
    
    private func excuteGit(workingURL: URL, args: [String]) throws {
        
        let xcodeURL = NSApplication.appDelegate.xcodeURL
        guard let gitURL = xcodeURL?.appendingPathComponent("/Contents/Developer/usr/bin/git") else {
            
            throw GitError.other("git is not found.")
        }
        
        guard let reachable = try? workingURL.checkResourceIsReachable(),
            reachable else {
            
            throw GitError.other("URL is invalid")
        }
        
        let git = Process()
        git.launchPath = gitURL.path
        git.arguments = args
        
        git.currentDirectoryPath = workingURL.path
        
        let pipe = Pipe()
        git.standardError = pipe
        
        git.launch()
        git.waitUntilExit()
        
        guard git.terminationStatus == 0 else {
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let string = String(data: data, encoding: .utf8) ?? ""
            
            throw GitError.gitError(git.terminationStatus, string)
        }
        
    }
    
    private func clone() throws {
        
        let repositoryName = self.repositoryName
        guard repositoryName != "" else {
            
            throw GitError.other("URL is invalid.")
        }
        
        let args = ["clone", url.absoluteString, repositoryName]
        
        let workingURL = ApplicationDirecrories.support
        guard checkDirectory(workingURL) else {
            
            throw GitError.other("App Suport Directory is invalid.")
        }
        
        try excuteGit(workingURL: workingURL, args: args)
    }
    
    private func submoduleUpdate(shuldInit: Bool = false) throws {
        
        let workingURL = ApplicationDirecrories.support.appendingPathComponent(repositoryName)
        
        let args: [String] = {
            if shuldInit {
                
                return ["submodule", "update", "-i"]
            } else {
                
                return ["submodule", "update"]
            }
        }()
        
        try excuteGit(workingURL: workingURL, args: args)
    }
    
    private func pul() throws {
        
        let workingURL = ApplicationDirecrories.support.appendingPathComponent(repositoryName)
        
        let args = ["pull"]
        
        try excuteGit(workingURL: workingURL, args: args)
    }
    
    private func tryPull(completeHandler: ((GitError) -> ())?) {
    
        do {
            
            try pul()
            
            try submoduleUpdate()
            
            completeHandler?(GitError.none)
            
        } catch {
            
            switch error {
            case let e as GitError: completeHandler?(e)
                
            default: completeHandler?(GitError.other("Unknown Error: \(error)"))
            }
        }
    }
    
    private func repositoryName(for url: URL) -> String {
        
        if url.pathExtension == "git" {
            
            return url.deletingPathExtension().lastPathComponent
        }
        
        return url.lastPathComponent
        
    }
}
