import ArgumentParser

// MARK: - AddCommand
struct AddCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "add",
        abstract: "Path you want to add to your PATH Env variable"
    )

    @Argument(help: "Directory to add to the PATH")
    var path: String

    @Option(name: .long, help: "Skip sourcing the RC file after modification (true/false).")
    var skipSource: Bool?

    @Option(name: .long, help: "Create a backup of the RC file before adding a path (true/false).")
    var backup: Bool?

    func run() throws {
        let shouldSource = resolveSourcing(skipSource)
        let shouldBackup = resolveBackup(backup)

        try PathmanCli.shared.addToPath(path, sourcing: shouldSource, backup: shouldBackup)
    }
}

// MARK: - RemoveCommand
struct RemoveCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "remove",
        abstract: "Path you want to remove from your PATH Env variable"
    )

    @Argument(help: "Directory to remove from the PATH")
    var path: String

    @Option(name: .long, help: "Skip sourcing the RC file after modification (true/false).")
    var skipSource: Bool?

    @Option(name: .long, help: "Create a backup of the RC file before removing a path (true/false).")
    var backup: Bool?

    func run() throws {
        let shouldSource = resolveSourcing(skipSource)
        let shouldBackup = resolveBackup(backup)

        try PathmanCli.shared.removeFromPath(path, sourcing: shouldSource, backup: shouldBackup)
    }
}

// MARK: - PathmanCli
@main
struct PathmanCli: ParsableCommand {
    static var config: PathmanConfig {
        do {
            return try PathmanConfigManager().loadOrDefault()
        } catch {
            fatalError("Failed to load configuration: \(error.localizedDescription)")
        }
    }

    static let shared: Pathman = {
        do {
            return try Pathman(
                rcFileNameOverride: config.defaultRcFile,
                autoSourceDefault: config.autoSource ?? true,
                backupDefault: config.backup ?? false
            )
        } catch {
            fatalError("Failed to initialize Pathman: \(error.localizedDescription)")
        }
    }()

    static var configuration = CommandConfiguration(
        commandName: "pathman",
        abstract: """
                  Pathman is a little tool that helps you manage your shell RC files with ease, \
                  focusing on making your life a tad simpler when it comes to handling the PATH \
                  environment variable.
                  """,
        version: "Pathman v0.3",
        subcommands: [AddCommand.self, RemoveCommand.self]
    )
}
