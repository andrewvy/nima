import init
import seed
import build
import serve

import docopt, os, strutils

proc inNimaProject(): bool =
    let config_file = "config.json"
    result = existsFile(os.getCurrentDir()/config_file)

let DOC = """
    nima - static website generator in Nim

    Usage:
        nima init [-vs] [<project_name>]
        nima serve
        nima build
        nima generate <type> <name>
        nima -h, --help
        nima --version

    Options:
        -h, --help                 Show this screen
        --version                  Show version.
        -v                         Toggle verbose mode.
        -s                         Generates with seed data.
"""

let VERSION = "nima 0.1"

let args = docopt(DOC, version=VERSION)

if args["init"]:
    init(args)
else:
    if not inNimaProject():
        echo "Not currently in a Nima project!"
        quit()

    if args["serve"]:
        serve(args)
    if args["build"]:
        build(args)
    if args["generate"]:
        type_generate(args)
