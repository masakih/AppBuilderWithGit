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
