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
        
        XCTAssertTrue(existCommand("git"))
        
        XCTAssertFalse(existCommand("skjdlfkjsaldfjalkj"))
    }
    
    
    func testMatch() {
        
        XCTAssertTrue("hogehogehoge".match("hoge"))
        
        XCTAssertTrue("abcdefg".match("\\w*"))
        
        XCTAssertTrue("1234567890".match("\\w*"))
        
        XCTAssertTrue("Hoge.xcodeproj".match("\\w*\\.xcodeproj$"))
        
        XCTAssertFalse("Hoge.xcodeproj.copy".match("\\w*\\.xcodeproj$"))
        
        XCTAssertFalse(".xcodeproj.copy".match("\\w*\\.xcodeproj$"))
    }
}
