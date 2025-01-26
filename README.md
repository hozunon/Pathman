# Pathman: Effortless Shell Environment Management

Pathman is a small tool written in Swift that helps you manage your PATH environment variables.

## What Can Pathman Do?

- **Easy Shell Setup**: Pathman is able to detect what shell is being used (as long as its the one that is supported). It can read, modify and save your shell config files (.bashrc, .zshrc, .zprofile (as default for zsh shell) ) without setting it up. Pathman config can be also overridden in its `config.toml` to enforce what RC file to utilise at all times, including auto sourcing.

- **Add or Remove Directories**: Simply add or remove directories from your `PATH` environment variable within your shell configuration files. Pathman will check for duplicate entries!

## But why?

Because why not.

I wanted to create a small toy project that helps me combat my laziness. I wanted a quick way to add and remove PATH variables for Bash and Zsh, 
as these are the two shells I use most on my Mac device and Linux laptop. There are better ways of doing it, but this one is mine.

## TODO
- ~~Add automatic sourcing of RC file after removing or adding path. Few tests resulted in errors from the shell.~~ Sourcing file is now done automatically when adding or removing path. User can skip sourcing by passing flag --skip-source after the path
- ~~Add config file that helps Pathman determine custom RC files to manage (TOML? YAML?)~~ Pathman will now read config file from .config/pathman/config.toml that determines overridden rcFile and auto sourcing
```toml
defaultRcFile = ".zprofile"
autoSource = true
```
- Create backup on demand of RC file or custom RC file
- Add support for different environment variables? (LD_LIBRARY_PATH, PKG_CONFIG_PATH)
- More?
