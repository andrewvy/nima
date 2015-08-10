import types
import os
import strutils
import docopt

proc init(args: Table) =
    var F_VERBOSE = false
    var CURRENT_DIR: string
    var project_file, project_name: string
    var project_file_out: File

    if args["-v"]:
        F_VERBOSE = true

    if args["<project_name>"]:
        project_name = $args["<project_name>"]
    else:
        echo "Please enter in a project name: "
        project_name = readLine(stdin)

    echo "Initializing new Nima project!"

    # Init project directory
    project_file = "config.toml"
    CURRENT_DIR = os.getCurrentDir()

    try:
        if existsDir(CURRENT_DIR / project_name):
            raise newException(NimaError, "Directory already exists with that name: " & project_name)
        createDir(CURRENT_DIR / project_name)
    except NimaError:
        echo "ERROR: " & getCurrentExceptionMsg()

    # Init config files

    try:
        if existsFile(CURRENT_DIR / project_name / project_file):
            raise newException(NimaError, "Nima project file already exists in project directory!")
        if open(f=projectFileOut, filename = CURRENT_DIR/project_name/project_file, mode = fmWrite):
            projectFileOut.writeln("title = \"" & project_name & "\"")
            projectFileOut.writeln("version = \"0.1.0\"")
            projectFileOut.writeln("author = \"Anonymous\"")
            close(projectFileOut)
        else:
            raise newException(NimaError, "Failed to create .nima config file")
    except NimaError:
        echo "ERROR: " & getCurrentExceptionMsg()
