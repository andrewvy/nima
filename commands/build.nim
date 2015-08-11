import types

import docopt
import os
import strutils

proc compile_html(CURRENT_DIR: string) =
    echo "Compiling HTML"

proc build*(args: Table) =
    let CURRENT_DIR = os.getCurrentDir()
    let CONFIG_FILE = "config.toml"

    try:
        if existsFile(CURRENT_DIR/CONFIG_FILE):
            echo "Building Nima project.."
            compile_html(CURRENT_DIR)
        else:
            raise newException(NimaError, "Not currently in a Nima project!")
    except NimaError:
        echo "ERROR: " & getCurrentExceptionMsg()
