import seed_includes
import types

import os
import docopt
import strutils

proc type_seed*(args: Table) =
    echo "Type seed"

proc template_seed*(args: Table) =
    echo "Template seed.."

proc sample_seed*(args: Table) =
    let project_dir = args["project_dir"]
    let dirs = ["partials", "post"]

    # Create dirs
    for dir in dirs:
        try:
            createDir(project_dir / "layouts" / dir )
        except NimaError:
            echo "ERROR: " & getCurrentExceptionMsg()

    # Create seed files
    var seed_data = init_table[string, string]()
    seed_data["partials/header.html"] = seed_header
    seed_data["partials/footer.html"] = seed_footer
    seed_data["index.static.html"] = seed_index
    seed_data["post/single.html"] = seed_post

    for filename, data in seed_data:
        try:
            if existsFile(project_dir / "layouts" / filename):
                raise newException(NimaError, "Nima project file already exists in project directory!")
            try:
                writeFile(project_dir / "layouts" / filename, data)
            except IOError:
                echo: "ERROR: " & getCurrentExceptionMsg()

        except NimaError:
            echo "ERROR: " & getCurrentExceptionMsg()
