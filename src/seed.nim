import seed_includes
import types

import os, docopt, strutils, times

proc write_seed*(name: string, dir: string, data: string) =
    try:
        writeFile(dir/name, data)
    except IOError:
        echo "ERROR: " & getCurrentExceptionMsg()

proc type_generate*(args: Table) =
    let project_dir = os.getCurrentDir()
    let name = $args["<name>"]
    let name_date = name & "-" & getDateStr() & "-" & getClockStr()

    case $args["<type>"]
        of "layout":
            echo "Creating layout.. " & project_dir / "layouts" / name / name & ".html"
            if not dirExists(project_dir / "layouts" / name):
                createDir(project_dir / "layouts" / name)
            write_seed(name&".html", project_dir/"layouts"/name&"/", seed_layout(name))
        of "partial":
            echo "Creating partial.. " & project_dir / "layouts/partials" / name & ".html"
            write_seed(name&".html", project_dir/"layouts/partials", seed_partial(name))
        of "content":
            echo "Creating content.. " & project_dir / "content" / name / name_date & ".md"
            if not dirExists(project_dir / "content" / name):
                createDir(project_dir / "content" / name)
            write_seed(name_date&".md", project_dir/"content"/name, seed_content(name))

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
                echo "ERROR: " & getCurrentExceptionMsg()

        except NimaError:
            echo "ERROR: " & getCurrentExceptionMsg()
