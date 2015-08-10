import types
import os
import strutils
import docopt

proc init(args: Table) =
    var F_VERBOSE = false
    var CURRENT_DIR: string
    var project_file, project_name: string

    if args["-v"]:
        F_VERBOSE = true

    if args["<project_name>"]:
        project_name = $args["<project_name>"]
    else:
        echo "Please enter in a project name: "
        project_name = readLine(stdin)

    echo "Initializing new Nima project!"

    # Init project directory
    project_file = project_name & ".nima"
    CURRENT_DIR = os.getCurrentDir()

    try:
        if existsDir(CURRENT_DIR / project_name):
            raise newException(NimaError, "Directory already exists with that name: " & project_name)

        createDir(CURRENT_DIR / project_name)

    except NimaError:
        echo "ERROR: " & getCurrentExceptionMsg()

    # Init config files

    echo args
