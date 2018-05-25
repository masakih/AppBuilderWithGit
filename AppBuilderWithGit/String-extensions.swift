//
//  String-extensions.swift
//  AppBuilderWithGit
//
//  Created by Hori,Masaki on 2018/04/08.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Foundation

extension String {
    
    func match(_ pattern: String, options: NSRegularExpression.Options = []) -> Bool {
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            
            return false
        }
        
        let matches = regex.rangeOfFirstMatch(in: self, options: [], range: NSMakeRange(0, self.count))
        
        return matches.location != NSNotFound
    }
}
