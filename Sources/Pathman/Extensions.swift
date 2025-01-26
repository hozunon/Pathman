//
//  File.swift
//  Pathman
//
//  Created by Hozu on 26/01/2025.
//

import Foundation
import ArgumentParser

// MARK: - Shared Logic
extension ParsableCommand {
    /// Resolves whether sourcing should happen based on CLI options and config.
    func resolveSourcing(_ skipSourceOption: Bool?) -> Bool {
        if let skipSource = skipSourceOption {
            return !skipSource // Explicit CLI override
        } else {
            return PathmanCli.config.autoSource ?? true // Fallback to config
        }
    }

    /// Resolves whether backup should happen based on CLI options and config.
    func resolveBackup(_ backupOption: Bool?) -> Bool {
        return backupOption ?? PathmanCli.config.backup ?? false // CLI override or fallback to config
    }
}
