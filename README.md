# Nima

Simple static website generator in [Nim](http://nim-lang.org/)

# Installation

_This project is currently in progress._

```
git clone https://github.com/andrewvy/nima
cd nima

# If you want to use Nimble
nimble install

# Else, you can manually compile the binary
nim c nima.nim
```

# Get Started

Initialize a new Nima project!

`nima init -vs new_project_folder`

Compile and build the seed data!
`cd new_project_folder`
`nima build`

# Usage

```
    nima - static website generator in Nim

    Usage:
        nima init [-vs] [<project_name>]
        nima serve
        nima build
        nima seed <type> <name>
        nima -h, --help
        nima --version

    Options:
        -h, --help                 Show this screen
        --version                  Show version.
        -v                         Toggle verbose mode.
        -s                         Generates with seed data.
```
