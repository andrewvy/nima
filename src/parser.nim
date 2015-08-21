import types

import os, streams, tables, strutils, re, json, stopwatch

proc format_path*(current_dir: string, file_path: string): string =
    let s = splitFile(file_path)
    result = "public/" & s[1].replace(".static", "") & s[2]

proc add_file*(f: FileItem): File = open(f.path)

proc parse_for_partials(l: Layout, partialPath: string, partialCache: Table[string, string]): string =
    # Parse for partials here..
    result = ""

    while true:
        var line = ""
        try:
            line = readLine(l.layout_file)
        except IOError:
            break

        var line_stripped = strip(line)
        var reg = re("\".*\"")

        # poor mans parser ¯\_(ツ)_/¯
        if line_stripped.startsWith("<partial src="):
            var matches = line_stripped.findAll(reg)
            if len(matches) > 0:
                var partialName = matches[0].copy(1, len(matches[0])-2)
                if partialCache.hasKey(partialPath & partialName):
                    result = result & partialCache[partialPath & partialName] & "\n"
                else:
                    echo "Could not find partial: " & partialPath & partialName
            else:
                result = result & line & "\n"
        else:
            result = result & line & "\n"

proc render_layout*(l: string, s: JsonNode): string = result = l

proc get_partial_data*(l: Layout): string =
    result = readAll(l.layout_file)
    l.layout_file.close()

proc get_layout_data*(l: Layout, partialDir: string, partialCache: Table[string, string]): string =
    result = parse_for_partials(l, partialDir, partialCache)
    l.layout_file.close()

proc write_layout*(path: string, data: string) =
    try:
        writeFile(path, data)
    except IOError:
        echo "ERROR: " & getCurrentExceptionMsg()

proc cache_layout*(layout: Layout, partialDir: string, partialCache: Table[string, string]): string =
    echo "Caching layout... " & layout.layout_path
    result = get_layout_data(layout, partialDir, partialCache)

proc cache_layouts*(layouts: seq[Layout], partialDir: string, partialCache: Table[string, string]): Table[string, string] =
    result = init_table[string, string]()

    for layout in layouts:
        result[layout.layout_path] = cache_layout(layout, partialDir, partialCache)

proc cache_partial*(partial: Layout): string =
    echo "Caching partial... " & partial.layout_path
    result = get_partial_data(partial)

proc cache_partials*(partials: seq[Layout]): Table[string, string] =
    result = init_table[string, string]()

    for partial in partials:
        result[partial.layout_path] = cache_partial(partial)

proc parse_content_json*(c: Content): JsonNode =
    var json, json_line = ""

    while true:
        try:
            json_line = c.content_file.readLine().strip()
        except IOError:
            echo "EOF, couldn't find JSON frontmatter."

        if len(json_line) != 0: break

    if json_line.startsWith("{"):
        json &= json_line

        while true:
            try:
                json_line = c.content_file.readLine().strip()
            except IOError:
                echo "Reached end of file! Malformed JSON frontmatter."
                break

            json &= json_line

            if json_line.startsWith("}"):
                break

    try:
        result = parseJson(json)
    except:
        echo "Invaid or missing JSON frontmatter"

proc parse_content_rst*(c: Content): string =
    # Parse content and separate JSON frontmatter from rst
    result = ""

    while true:
        var line = ""
        try:
            line = readLine(c.content_file)
        except IOError:
            break

        var line_stripped = line.strip()

        result = result & line & "\n"
