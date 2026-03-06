//
//  AppLogger.swift
//  ArticlesApp
//
//  Created by Mitul Tarsariya on 06/03/26.
//

import Foundation
import XCGLogger

/// Singleton wrapper around XCGLogger
final class AppLogger {
    
    static let shared = AppLogger()
    
    private let xcg: XCGLogger = {
        let logger = XCGLogger(identifier: "com.articlesapp.logger",
                               includeDefaultDestinations: false)
        return logger
    }()
    
    private init() { configure() }
    
    // MARK: - Setup
    private func configure() {
        // Console
        let console = ConsoleDestination(identifier: "com.articlesapp.console")
        console.showLogIdentifier  = false
        console.showFunctionName   = true
        console.showThreadName     = false
        console.showLevel          = true
        console.showFileName      = true
        console.showLineNumber    = true
        console.outputLevel        = Environment.current.isLoggingEnabled ? .debug : .warning
        xcg.add(destination: console)
        
        // File (warnings+ only in production)
        if let docDir = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask).first {
            let logFile = docDir.appendingPathComponent("ArticlesApp.log")
            let file = FileDestination(writeToFile: logFile,
                                       identifier: "com.articlesapp.file",
                                       shouldAppend: true,
                                       appendMarker: "-- Launch --")
            file.outputLevel    = .warning
            file.showLogIdentifier = false
            file.showFunctionName  = true
            file.showLevel         = true
            file.showFileName     = true
            file.showLineNumber   = true
            xcg.add(destination: file)
        }
        
        xcg.logAppDetails()
    }
    
    // MARK: - Public Interface
    func verbose(
        _ msg: @autoclosure () -> Any?,
        file: StaticString = #file,
        function: StaticString = #function,
        line: Int = #line
    ) {
        xcg.verbose(msg(), functionName: function, fileName: file, lineNumber: line)
    }
    
    func debug(
        _ msg: @autoclosure () -> Any?,
        file: StaticString = #file,
        function: StaticString = #function,
        line: Int = #line
    ) {
        xcg.debug(msg(), functionName: function, fileName: file, lineNumber: line)
    }
    
    func info(
        _ msg: @autoclosure () -> Any?,
        file: StaticString = #file,
        function: StaticString = #function,
        line: Int = #line
    ) {
        xcg.info(msg(), functionName: function, fileName: file, lineNumber: line)
    }
    
    func warning(
        _ msg: @autoclosure () -> Any?,
        file: StaticString = #file,
        function: StaticString = #function,
        line: Int = #line
    ) {
        xcg.warning(msg(), functionName: function, fileName: file, lineNumber: line)
    }
    
    func error(
        _ msg: @autoclosure () -> Any?,
        file: StaticString = #file,
        function: StaticString = #function,
        line: Int = #line
    ) {
        xcg.error(msg(), functionName: function, fileName: file, lineNumber: line)
    }
}

