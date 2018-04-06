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
            
            try submoduleUpdate(shouldInit: true)
            
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
        
        guard !args.isEmpty else {
            
            throw GitError.other("Iligal arguments")
        }
        
        let xcodeURL = NSApplication.appDelegate.xcodeURL
        guard let gitURL = xcodeURL?.appendingPathComponent("/Contents/Developer/usr/bin/git") else {
            
            throw GitError.other("git is not found.")
        }
        
        guard let reachable = try? workingURL.checkResourceIsReachable(),
            reachable else {
            
            throw GitError.other("URL is invalid")
        }
        
        let git = Process() <<< gitURL.path <<< args
        
        git.currentDirectoryPath = workingURL.path
        
        let errorString = git >>> { (stdout, stderr) -> String in
            
            let log = LogStocker("git-" + args[0] + ".log")
            log?.write(stdout.data)
            
            let errorString = stderr.string
            errorString.map { log?.write($0) }
            
            return errorString ?? ""
        }
        
        git.waitUntilExit()
        
        guard git.terminationStatus == 0 else {
            
            throw GitError.gitError(git.terminationStatus, errorString)
        }
        
    }
    
    private func clone() throws {
        
        let repositoryName = self.repositoryName
        guard repositoryName != "" else {
            
            throw GitError.other("URL is invalid.")
        }
        
        let workingURL = ApplicationDirecrories.support
        guard checkDirectory(workingURL) else {
            
            throw GitError.other("App Support Directory is invalid.")
        }
        
        let args = ["clone", url.absoluteString, repositoryName]
        
        try excuteGit(workingURL: workingURL, args: args)
    }
    
    private func submoduleUpdate(shouldInit: Bool = false) throws {
        
        let workingURL = ApplicationDirecrories.support.appendingPathComponent(repositoryName)
        
        let args = shouldInit ? ["submodule", "update", "-i"] : ["submodule", "update"]
        
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
