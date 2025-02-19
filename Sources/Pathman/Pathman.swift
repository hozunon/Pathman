//
//  Pathman.swift
//
//
//  Created by Hozu on 07/03/2024.
//  Edited by Hozu on 25/01/2025.
//

import Foundation

// MARK: - Shell Enum

enum Shell: String, CaseIterable {
    case bash, zsh
    
    var rcFileName: String {
        switch self {
        case .bash:
            return ".bashrc"
        case .zsh:
            let fileManager = FileManager.default
            let homeURL = fileManager.homeDirectoryForCurrentUser
            let zprofilePath = homeURL.appendingPathComponent(".zprofile")
            let zshrcPath = homeURL.appendingPathComponent(".zshrc")
            
            if fileManager.fileExists(atPath: zprofilePath.path) {
                return ".zprofile"
            } else if fileManager.fileExists(atPath: zshrcPath.path) {
                return ".zshrc"
            } else {
                return ".zshrc"
            }
        }
    }
    
    static func from(shellPath: String) -> Shell? {
        allCases.first { shellPath.hasSuffix($0.rawValue) }
    }
}

// MARK: - Pathman Error

enum PathmanError: Error, LocalizedError {
    case shellNotFound
    case directoryNotFound(String)
    case sourceFailure(String)
    
    var errorDescription: String? {
        switch self {
        case .shellNotFound:
            return "SHELL environment variable not found or unsupported"
        case .directoryNotFound(let directory):
            return "Failed to remove directory '\(directory)' from PATH: Directory not found in PATH"
        case .sourceFailure(let reason):
            return "Failed to source RC file: \(reason)"
        }
    }
}

// MARK: - Pathman Implementation

struct Pathman {
    private let fileManager: FileManager
    private let shell: Shell
    private let filePath: URL
    private let autoSourceDefault: Bool
    private let backupDefault: Bool
    
    init(fileManager: FileManager = .default,
         rcFileNameOverride: String? = nil,
         autoSourceDefault: Bool = true,
         backupDefault: Bool = false)
    throws {
        
        self.fileManager = fileManager
        let homeURL = fileManager.homeDirectoryForCurrentUser
        
        guard let shellPath = ProcessInfo.processInfo.environment["SHELL"],
              let detectedShell = Shell.from(shellPath: shellPath) else {
            throw PathmanError.shellNotFound
        }
        
        shell = detectedShell
        filePath = rcFileNameOverride.map {
            homeURL.appendingPathComponent($0)
        } ?? homeURL.appendingPathComponent(shell.rcFileName)

        self.autoSourceDefault = autoSourceDefault
        self.backupDefault = backupDefault
    }
    
    func addToPath(_ directory: String, sourcing: Bool? = nil, backup: Bool? = nil) throws {
        try modifyPath(action: .add(directory), sourcing: sourcing ?? autoSourceDefault, backup: backup ?? backupDefault)
    }
    
    func removeFromPath(_ directory: String, sourcing: Bool? = nil, backup: Bool? = nil) throws {
        try modifyPath(action: .remove(directory), sourcing: sourcing ?? autoSourceDefault, backup: backup ?? backupDefault)
    }
    
    private enum PathAction {
        case add(String)
        case remove(String)
        
        var directory: String {
            switch self {
            case .add(let dir), .remove(let dir):
                return dir
            }
        }
    }
    
    private func modifyPath(action: PathAction, sourcing: Bool, backup: Bool) throws {
        var content = try String(contentsOf: filePath)
        
        if backup {
            let backupURL = filePath.deletingPathExtension().appendingPathExtension("bak")
            print("Backing up \(shell.rcFileName) to \(backupURL.lastPathComponent)")
            try fileManager.copyItem(at: filePath, to: backupURL)
        }
        
        switch action {
        case .add(let directory):
            
            guard !isDirectoryInPath(directory, content: content) else {
                print("Directory '\(directory)' is already in PATH. No changes made.")
                return
            }
            
            content += "\nexport PATH=\"\(directory):$PATH\""
            print("Directory added to PATH in \(shell.rcFileName)")
            
        case .remove:
            guard let range = content.range(of: "export PATH=\".*\(action.directory):.*\"", options: .regularExpression) else {
                throw PathmanError.directoryNotFound(action.directory)
            }
            
            content.removeSubrange(range)
            content = content
                .replacingOccurrences(of: "export PATH=\":$PATH\"", with: "")
            
                .replacingOccurrences(of: "\n+", with: "\n", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            print("Directory removed from PATH in \(shell.rcFileName)")
        }
        
        try content.write(to: filePath, atomically: true, encoding: .utf8)
        
        if sourcing {
            do {
                try runCmd("source \(filePath.path)")
                print("Sourced \(filePath.path) successfully")
            } catch {
                throw PathmanError.sourceFailure(error.localizedDescription)
            }
        } else {
            print("\nTo apply changes, run this command in your terminal:")
            print("source \(filePath.path)")
        }
    }
    
    private func isDirectoryInPath(_ directory: String, content: String) -> Bool {
        let pattern = "export PATH=\"(.*\(directory):.*)\"|export PATH=\"(.*:\(directory).*)\""
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(content.startIndex..., in: content)
        return regex?.firstMatch(in: content, options: [], range: range) != nil
    }
    
    @discardableResult
    private func runCmd(_ command: String) throws -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: "/bin/\(shell.rawValue)")
        
        try task.run()
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }
}
