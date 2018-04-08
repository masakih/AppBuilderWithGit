//
//  CommandFinder.swift
//  AppBuilderWithGit
//
//  Created by Hori,Masaki on 2018/04/06.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Foundation

func existCommand(_ commandName: String) -> Bool {
    
    return Process() <<< "/usr/bin/which" <<< [commandName]
        >>> { output in output.lines.count == 2 }
}

func commandPath(_ commandName: String) -> URL? {
    
    let which = Process() <<< "/usr/bin/which" <<< [commandName]
    if let currentPath = which.environment?["PATH"] {
        
        print(currentPath)
        which.environment!["PATH"] = "/usr/local/bin/:" + currentPath
    } else {
        which.environment = ["PATH": "/bin:/sbin:/local/bin:/local/sbin:/usr/local/bin"]
    }
    return which >>> { (output: Output) -> URL? in
            
            let lines = output.lines
            
            print(lines)
            
            guard let path = lines.first else {
                return nil
            }
            
            return URL(fileURLWithPath: path)
    }
}
