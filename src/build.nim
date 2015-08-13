import types
import parser

import os, docopt, tables, strutils

proc writeTemplate(path: string, data: string) =
    writeFile(path, data)

proc makeDirs(dirs: seq[string]) =
    for dir in dirs:
        if not dirExists("public/" & dir): createDir("public/" & dir)

proc compile_html(project_dir: string, c: FileCollection) =
    const INDEX_FILE = "layouts/index.html"
    const PUBLIC_DIR = "public"
    var partial_layouts, static_layouts, compiled_layouts = newSeq[Layout]()
    let files = c.fileitems

    # Split files between layout types: Partial, Static, Compiled
    for file in files:
        var l = Layout()
        var f = addTemplateFile(file)

        if file.path.contains("partial"):
            l.layout_type = PartialLayout
            l.layout_file = f
            partial_layouts.add(l)
        elif file.filename.contains(".static"):
            l.layout_type = StaticLayout
            l.layout_file = f
            static_layouts.add(l)
        else:
            l.layout_type = CompiledLayout
            l.layout_file = f
            compiled_layouts.add(l)

proc compile(project_dir: string, t: Table[string, FileCollection]) =
    for key, c in t:
        case key
            of ".html": compile_html(project_dir, c)
            else: discard

proc build_file_hash(current_dir: string): Table[string, FileCollection] =
    result = init_table[string, FileCollection]()

    for path in walkDirRec(current_dir):
        if path.contains("public"): continue

        var i = FileItem()
        var c = FileCollection()
        let s = splitFile(path)

        i.path = path
        i.localpath = s[0].replace("layouts", "").copy(len(current_dir)+1)
        i.filepath = s[0]
        i.filename = s[1]
        i.fileext = s[2]

        if not result.hasKey(i.fileext):
            c.fileext = i.fileext
            result.add(i.fileext, c)

        c = result[i.fileext]
        if len(c.fileitems) == 0:
            c.fileitems = @[]

        add(c.fileitems, i)


proc build*(args: Table) =
    let current_dir = os.getCurrentDir()
    let config_file = "config.toml"

    try:
        if existsFile(current_dir/config_file):
            echo "Building Nima project.."
            var file_hash = build_file_hash(current_dir)
            compile(current_dir, file_hash)
        else:
            raise newException(NimaError, "Not currently in a Nima project!")
    except NimaError:
        echo "ERROR: " & getCurrentExceptionMsg()
