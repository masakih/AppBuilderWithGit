//
//  AppBuilderWithGitTests.swift
//  AppBuilderWithGitTests
//
//  Created by Hori,Masaki on 2018/04/06.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import XCTest

@testable import AppBuilderWithGit

class AppBuilderWithGitTests: XCTestCase {
    
    func testExistCommand() {
        
        XCTAssertTrue(existCommand("carthage"))
        XCTAssertTrue(existCommand("pod"))
        
        XCTAssertFalse(existCommand("skjdlfkjsaldfjalkj"))
    }
    
    func testCommandPath() {
        
        XCTAssertEqual(commandPath("carthage")?.path, "/usr/local/bin/carthage")
        XCTAssertEqual(commandPath("pod")?.path, "/usr/local/bin/pod")
    }
    
    func testMatch() {
        
        XCTAssertTrue("hogehogehoge".match("hoge"))
        
        XCTAssertTrue("abcdefg".match("\\w*"))
        
        XCTAssertTrue("1234567890".match("\\w*"))
        
        XCTAssertTrue("Hoge.xcodeproj".match("\\w*\\.xcodeproj$"))
        
        XCTAssertFalse("Hoge.xcodeproj.copy".match("\\w*\\.xcodeproj$"))
        
        XCTAssertFalse(".xcodeproj.copy".match("\\w*\\.xcodeproj$"))
        
        
        XCTAssertTrue("Cartfile".match("^Cartfile$"))
        XCTAssertFalse("hogeCartfile".match("^Cartfile$"))
        XCTAssertFalse("Cartfilehoge".match("^Cartfile$"))

    }
    
    
    func testFileFinder() {
        
        let bundleURL = Bundle.main.bundleURL
        
        XCTAssertNotNil(findFile(pattern: "Contents", in: bundleURL))
        
        XCTAssertNotNil(findFile(pattern: "PkgInfo", in: bundleURL, depth: 3))
        
        XCTAssertNil(findFile(pattern: "pkgInfo", in: bundleURL, depth: 3))
        
    }
}
