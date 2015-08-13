import types

import os, streams, tables, strutils, re, json, stopwatch

proc format_path*(current_dir: string, file_path: string): string =
    let s = splitFile(file_path)
    result = "public/" & s[1].replace(".static", "") & s[2]

proc add_template_file*(f: FileItem): File = open(f.path)

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
