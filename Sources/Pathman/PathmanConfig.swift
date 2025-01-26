//
//  PathmanConfig.swift
//  Pathman
//
//  Created by Hozu on 25/01/2025.
//

import Foundation
import TOMLKit

// MARK: - PathmanConfig

struct PathmanConfig: Decodable {
    var defaultRcFile: String?
    var autoSource: Bool?
}

struct PathmanConfigManager {
    private let configURL: URL
    
    init() throws {
        let fileManager = FileManager.default
        let configDirectory = fileManager.homeDirectoryForCurrentUser
            .appendingPathComponent(".config/pathman")
            
        // create dir if it doesn't exist
        if !fileManager.fileExists(atPath: configDirectory.path) {
            try fileManager.createDirectory(at: configDirectory, withIntermediateDirectories: true)
        }
        
        self.configURL = configDirectory.appendingPathComponent("config.toml")
    }
    
    func loadOrDefault() throws -> PathmanConfig {
        guard FileManager.default.fileExists(atPath: configURL.path),
              let contents = try? String(contentsOf: configURL),
              !contents.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            // If the file doesn't exist or is empty/invalid,
            // return defaults immediately.
            return PathmanConfig(defaultRcFile: nil, autoSource: true)
        }

        do {
            let table = try TOMLTable(string: contents)
            let config = try TOMLDecoder().decode(PathmanConfig.self, from: table)
            return PathmanConfig(
                defaultRcFile: config.defaultRcFile,
                autoSource: config.autoSource ?? true
            )
        } catch {
            // If parsing fails for any reason, return defaults.
            return PathmanConfig(defaultRcFile: nil, autoSource: true)
        }

    }
}
