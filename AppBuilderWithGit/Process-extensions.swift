//
//  Process-extensions.swift
//  AppBuilderWithGit
//
//  Created by Hori,Masaki on 2018/04/06.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Foundation

/// 出力を簡単に扱うための補助的な型。FileHandleを隠蔽する。
struct Output {
    
    private let fileHandle: FileHandle
    
    init(fileHandle: FileHandle) {
        self.fileHandle = fileHandle
    }
    
    var data: Data {
        return fileHandle.readDataToEndOfFile()
    }
    
    var string: String? {
        return String(data: data, encoding: .utf8)
    }
    
    var lines: [String] {
        return string?.components(separatedBy: "\n") ?? []
    }
}

precedencegroup ArgumentPrecedence {
    
    associativity: left
    higherThan: AdditionPrecedence
}
infix operator <<< : ArgumentPrecedence

/// Processにexecutable pathを設定する。
func <<< (lhs: Process, rhs: String) -> Process {
    
    lhs.launchPath = rhs
    return lhs
}

/// Processに引数を設定する。
func <<< (lhs: Process, rhs: [String]) -> Process {
    
    lhs.arguments = rhs
    return lhs
}

/// Processをパイプする。
func | (lhs: Process, rhs: Process) -> Process {
    
    let pipe = Pipe()
    
    lhs.standardOutput = pipe
    rhs.standardInput = pipe
    lhs.launch()
    
    return rhs
}

precedencegroup RedirectPrecedence {
    
    associativity: left
    lowerThan: LogicalDisjunctionPrecedence
}
infix operator >>> : RedirectPrecedence

/// Processの出力をOutput型で受け取り加工などができる。
/// ジェネリクスを利用しているのでどのような型にでも変換して返せる。
func >>> <T>(lhs: Process, rhs: (Output) -> T) -> T {
    
    let pipe = Pipe()
    lhs.standardOutput = pipe
    lhs.launch()
    
    return rhs(Output(fileHandle: pipe.fileHandleForReading))
}

func >>> <T>(lhs: Process, rhs: (Output, Output) -> T) -> T {
    
    let pipe = Pipe()
    lhs.standardOutput = pipe
    
    let err = Pipe()
    lhs.standardError = err
    
    lhs.launch()
    
    return rhs(Output(fileHandle: pipe.fileHandleForReading), Output(fileHandle: err.fileHandleForReading))
}

