//
//  LogStocker.swift
//  AppBuilderWithGit
//
//  Created by Hori,Masaki on 2017/08/13.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

private func fileURL(for name: String) -> URL? {
    
    let base = ApplicationDirecrories.support.appendingPathComponent("Logs")
    guard checkDirectory(base) else {
        
        return base.appendingPathComponent(name)
    }
    
    return base.appendingPathComponent(name)
}

private func nameWithDate(_ name: String) -> String {
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss-A"
    
    return formatter.string(from: Date()) + "-" + name
    
}

final class LogStocker {
    
    private let output: FileHandle
    
    init?(_ name: String) {
        
        do {
            
            let datename = nameWithDate(name)
            guard let url = fileURL(for: datename) else { return nil }
            
            try Data().write(to: url)
            
            output = try FileHandle(forWritingTo: url)
            
        } catch {
            
            print("can not open file for log writing.\n\(error)")
            
            return nil
        }
        
    }
    
    deinit { output.closeFile() }
    
    func read(_ fileHandle: FileHandle) {
        
        DispatchQueue.global().async {
            
            self.output.write(fileHandle.readDataToEndOfFile())
        }
        
    }
    
    func write(_ data: Data) {
        
        DispatchQueue.global().async {
            
            self.output.write(data)
        }
    }
    
}
