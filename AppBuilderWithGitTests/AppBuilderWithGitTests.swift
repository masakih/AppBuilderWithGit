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
    
}
