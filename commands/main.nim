include init
include serve

import docopt
import strutils

let DOC = """
    nima - static website generator in Nim

    Usage:
        nima init [-v] <project_name>
        nima serve (-p=<port>)
        nima -h, --help
        nima --version

    Options:
        -h, --help          Show this screen
        --version           Show version.
        -v                  Toggle verbose mode.
        -p                  Set port [default=3005].
"""

let VERSION = "nima 0.1"

let args = docopt(DOC, version=VERSION)

if args["init"]:
    init($args)

if args["serve"]:
    echo "Development web server started on port $1" % [$args["port"]]

