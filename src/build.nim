import consts
import types
import parser

import os, docopt, tables, strutils, json, stopwatch

proc writeTemplate(path: string, data: string) =
    writeFile(path, data)

proc makeDirs(dirs: seq[string]) =
    # Automatically create public folder if there isn't one..
    if not dirExists("public"): createDir("public")

    for dir in dirs:
        if not dirExists("public/" & dir): createDir("public/" & dir)

proc compile_static_templates(project_dir: string, static_layouts: seq[Layout], partialDir: string, partialCache: Table[string, string], project_data: JsonNode) =
    let current_dir = os.getCurrentDir()
    var cl: clock
    cl.start()

    for layout in static_layouts:
        let rendered_layout: string = render_layout(get_layout_data(layout, partialDir, partialCache), project_data)
        write_layout(format_path(current_dir, layout.layout_path), rendered_layout)

    cl.stop()

    echo "Completed template compilation in "& ($(float(cl.clockStop - cl.clockStart)/1000000) & "ms")

proc compile(project_dir: string, t: Table[string, FileCollection]) =
    let current_dir = os.getCurrentDir()
    let partial_dir = current_dir / "layouts/partials/"
    let project_data = parseFile(current_dir/CONFIG_FILE)
    var partial_layouts, static_layouts, compiled_layouts = newSeq[Layout]()
    var partialCache, layoutCache = init_table[string, string]()

    if t.hasKey(".html"):
        var c = t[".html"]
        const INDEX_FILE = "layouts/index.html"
        const PUBLIC_DIR = "public"

        # Split files between layout types: Partial, Static, Compiled
        for file in c.fileitems:
            var l = Layout()
            var f = add_file(file)

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

    compile_static_templates(project_dir, static_layouts, partial_dir, partialCache, project_data)

    if t.hasKey(".md"):
        var filecol = t[".md"]

        for file in filecol.fileitems:
            var c = Content()
            c.content_file = add_file(file)

            # Parse JSON frontmatter
            let content_json = parse_content_json(c)
            let content_markdown = parse_content_markdown(c)

            echo content_json["title"]
            echo content_markdown

            # TODO: (vy) Actually use the JSON + MD to render out to the content template

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

    try:
        if existsFile(current_dir/CONFIG_FILE):
            echo "Building Nima project.."
            var file_hash = build_file_hash(current_dir)

            compile(current_dir, file_hash)
        else:
            raise newException(NimaError, "Not currently in a Nima project!")
    except NimaError:
        echo "ERROR: " & getCurrentExceptionMsg()
