import seed
import types

import os
import strutils
import docopt

proc init*(args: Table) =
    var F_VERBOSE, F_SEED = false
    var WORK_DIRS = ["assets", "assets/javascripts", "assets/stylesheets", "content", "public", "static", "layouts"]
    var CURRENT_DIR: string
    var project_file, project_name: string
    var project_file_out: File

    if args["-v"]:
        F_VERBOSE = true

    if args["-s"]:
        F_SEED = true

    if args["<project_name>"]:
        project_name = $args["<project_name>"]
    else:
        echo "Please enter in a project name: "
        project_name = readLine(stdin)

    # Init project directory
    project_file = "config.toml"
    CURRENT_DIR = os.getCurrentDir()

    try:
        if existsDir(CURRENT_DIR / project_name):
            raise newException(NimaError, "Directory already exists with that name: " & project_name & "/")
        if (F_VERBOSE):
            echo "Initializing main directory >> " & project_name & "/"
        createDir(CURRENT_DIR / project_name)
    except NimaError:
        echo "ERROR: " & getCurrentExceptionMsg()
        quit()

    echo "Initializing new Nima project! >> " & project_name & "/"

    # Init config files
    try:
        if existsFile(CURRENT_DIR / project_name / project_file):
            raise newException(NimaError, "Nima project file already exists in project directory!")
        if open(f=projectFileOut, filename = CURRENT_DIR/project_name/project_file, mode = fmWrite):
            if (F_VERBOSE):
                echo "Creating config file >> " & project_name/project_file
            projectFileOut.writeln("title = \"" & project_name & "\"")
            projectFileOut.writeln("version = \"0.1.0\"")
            projectFileOut.writeln("author = \"Anonymous\"")
            close(projectFileOut)
        else:
            raise newException(NimaError, "Failed to create .nima config file")
    except NimaError:
        echo "ERROR: " & getCurrentExceptionMsg()

    # Create work directories
    for dir in WORK_DIRS:
        try:
            if (F_VERBOSE):
                echo "Creating work dir >> " & project_name/dir
            createDir(CURRENT_DIR / project_name / dir )
        except NimaError:
            echo "ERROR: " & getCurrentExceptionMsg()

    if F_SEED:
        var options = init_table[string, string]()
        options["project_dir"] = CURRENT_DIR/project_name
        if (F_VERBOSE):
            echo "Copying seed project data >> " & project_name
        sample_seed(options)
