import init
import seed
import build
import serve

import docopt
import strutils

let DOC = """
    nima - static website generator in Nim

    Usage:
        nima init [-vs] [<project_name>]
        nima serve (--port=<port>)
        nima build
        nima seed <type>
        nima -h, --help
        nima --version

    Options:
        -h, --help                 Show this screen
        --version                  Show version.
        -v                         Toggle verbose mode.
        -s                         Generates with seed data.
        -p=<port>, --port=<port>   Set port [default=3005].
"""

let VERSION = "nima 0.1"

let args = docopt(DOC, version=VERSION)

if args["init"]:
    init(args)
if args["serve"]:
    serve(args)
if args["build"]:
    build(args)
if args["seed"]:
    type_seed(args)
