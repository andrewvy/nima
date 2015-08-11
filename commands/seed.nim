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
    let partials = ["header", "footer"]

    # Create Partials
    var partial_data = init_table[string, string]()
    partial_data["partials/header.html"] = seed_header
    partial_data["partials/footer.html"] = seed_footer
    partial_data["index.html"] = seed_index

    for i, partial in ["partials/header.html", "partials/footer.html", "index.html"]:
        try:
            if existsFile(project_dir / "layouts" /partial):
                raise newException(NimaError, "Nima project file already exists in project directory!")
            try:
                writeFile(project_dir / "layouts" / partial, partial_data[partial])
            except IOError:
                echo: "ERROR: " & getCurrentExceptionMsg()

        except NimaError:
            echo "ERROR: " & getCurrentExceptionMsg()
