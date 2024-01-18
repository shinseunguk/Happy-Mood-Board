//
//  TraceLog.swift
//  HappyMoodBoard
//
//  Created by ukBook on 1/13/24.
//

import Foundation


internal func traceLog(_ description: Any,
           fileName: String = #file,
           lineNumber: Int = #line,
           functionName: String = #function) {

    let traceString = "\(fileName.components(separatedBy: "/").last!) -> \(functionName) -> \(description) (line:\(lineNumber))"
    print(traceString)
}
