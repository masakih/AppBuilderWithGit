//
//  Carthage.swift
//  AppBuilderWithGit
//
//  Created by Hori,Masaki on 2018/04/08.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Foundation

final class Carthage {
    
    let baseURL: URL
    
    init(_ url: URL) {
        
        self.baseURL = url
        
        print("setting base url is", baseURL)
    }
    
    func execute() {
        
        guard findFile(pattern: "Cartfile$", in: baseURL) != nil else {
            
            print("Cartfile notFound")
            return
        }
        
        guard let carthageURL = commandPath("carthage") else {
            
            print("carthage not found")
            return
        }
        print("carthage", carthageURL)
        
        let carthage = Process() <<< carthageURL.path <<< ["update"]
        carthage.currentDirectoryPath = baseURL.path
        
        carthage.launch()
        carthage.waitUntilExit()
        
        if carthage.terminationStatus != 0 {
            
            print("Carthage error")
        }
    }
}
