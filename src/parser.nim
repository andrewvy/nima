import types

import os, streams, tables, strutils

proc format_path*(current_dir: string, file_path: string): string =
    let s = splitFile(file_path)
    result = "public/" & s[1].replace(".static", "") & s[2]

proc add_template_file*(f: FileItem): File = open(f.path)

proc parse_for_partials(l: Layout, partialCache: Table[string, string]): string =
    # Parse for partials here..
    echo "Parsing layout for partials.."
    result = readAll(l.layout_file)

proc get_partial_data*(l: Layout): string =
    result = readAll(l.layout_file)
    l.layout_file.close()

proc get_layout_data*(l: Layout, partialCache: Table[string, string]): string =
    result = parse_for_partials(l, partialCache)
    l.layout_file.close()

proc write_layout*(path: string, data: string) =
    try:
        writeFile(path, data)
    except IOError:
        echo "ERROR: " & getCurrentExceptionMsg()
