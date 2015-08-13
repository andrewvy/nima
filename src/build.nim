import types
import parser

import os, docopt, tables, strutils, json, stopwatch

proc writeTemplate(path: string, data: string) =
    writeFile(path, data)

proc makeDirs(dirs: seq[string]) =
    for dir in dirs:
        if not dirExists("public/" & dir): createDir("public/" & dir)

proc cache_layout(layout: Layout, partialDir: string, partialCache: Table[string, string]): string =
    echo "Caching layout... " & layout.layout_path
    result = get_layout_data(layout, partialDir, partialCache)

proc cache_layouts(layouts: seq[Layout], partialDir: string, partialCache: Table[string, string]): Table[string, string] =
    result = init_table[string, string]()

    for layout in layouts:
        result[layout.layout_path] = cache_layout(layout, partialDir, partialCache)

proc cache_partial(partial: Layout): string =
    echo "Caching partial... " & partial.layout_path
    result = get_partial_data(partial)

proc cache_partials(partials: seq[Layout]): Table[string, string] =
    result = init_table[string, string]()

    for partial in partials:
        result[partial.layout_path] = cache_partial(partial)

proc compile_html(project_dir: string, c: FileCollection, project_data: JsonNode) =
    var cl: clock
    cl.start()

    const INDEX_FILE = "layouts/index.html"
    const PUBLIC_DIR = "public"
    var partial_layouts, static_layouts, compiled_layouts = newSeq[Layout]()
    var partialCache, layoutCache = init_table[string, string]()
    let files = c.fileitems
    let current_dir = os.getCurrentDir()
    let partial_dir = current_dir / "layouts/partials/"

    # Split files between layout types: Partial, Static, Compiled
    for file in files:
        var l = Layout()
        var f = add_template_file(file)

        l.layout_path = file.path

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

    partialCache = cache_partials(partial_layouts)
    layoutCache = cache_layouts(compiled_layouts, partialDir, partialCache)

    for layout in static_layouts:
        let rendered_layout: string = render_layout(get_layout_data(layout, partialDir, partialCache), project_data)
        write_layout(format_path(current_dir, layout.layout_path), rendered_layout)

    cl.stop()

    echo "Completed template compilation in "& ($(float(cl.clockStop - cl.clockStart)/1000000) & "ms")

proc compile(project_dir: string, t: Table[string, FileCollection]) =
    let project_file = "config.json"
    var project_data = parseFile(os.getCurrentDir()/project_file)
    for key, c in t:
        case key
            of ".html": compile_html(project_dir, c, project_data)
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
    let config_file = "config.json"

    try:
        if existsFile(current_dir/config_file):
            echo "Building Nima project.."
            var file_hash = build_file_hash(current_dir)

            compile(current_dir, file_hash)
        else:
            raise newException(NimaError, "Not currently in a Nima project!")
    except NimaError:
        echo "ERROR: " & getCurrentExceptionMsg()
