//
//  PathmanCli.swift
//
//
//  Created by Hozu on 07/03/2024.
//  Edited by Hozu on 25/01/2025.
//

import ArgumentParser

struct AddCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "add",
        abstract: "Path you want to add to your PATH Env variable")
    
    @Argument(help: "Directory to add to the PATH")
    var path: String
    
    @Flag(name: .long, help: "Skip sourcing the RC file after modification")
    var skipSource = false
    
    func run() throws {
        try PathmanCli.shared.addToPath(path, sourcing: !skipSource)
    }
}

struct RemoveCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "remove",
        abstract: "Path you want to remove from your PATH Env variable")
    
    @Argument(help: "Directory to remove from the PATH")
    var path: String
    
    @Flag(name: .long, help: "Skip sourcing the RC file after modification")
    var skipSource = false
    
    func run() throws {
        try PathmanCli.shared.removeFromPath(path, sourcing: !skipSource)
    }
}

@main
struct PathmanCli: ParsableCommand {
    static let shared: Pathman = {
            do {
                let config = try PathmanConfigManager().loadOrDefault()
                return try Pathman(rcFileNameOverride: config.defaultRcFile, autoSourceDefault: config.autoSource ?? true)
            } catch {
                fatalError("Failed to initialize Pathman: \(error.localizedDescription)")
            }
        }()
    
    static var configuration = CommandConfiguration(
        commandName: "pathman",
        abstract: "Pathman is a little tool that helps you manage your shell RC files with ease, focusing on making your life a tad simpler when it comes to handling the PATH environment variable.",
        version: "Pathman v0.2",
        subcommands: [AddCommand.self, RemoveCommand.self])
}

