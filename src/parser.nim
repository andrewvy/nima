import types

import os, streams, tables, strutils

proc addTemplateFile*(f: FileItem): File = open(f.path)
proc injectPartials*(cache: Table[string, string], filepath: string, filedata: string): string =
    result = ""

proc parse_for_partials(l: Layout, partialCache: Table[string, string]): string =
    # Parse for partials here..
    echo "Parsing layout for partials.."

proc parse_and_write_layouts*(statics: seq[Layout], partialCache: Table[string, string]) =
    echo "Parsing static layouts"

proc get_partial_data*(l: Layout): string =
    result = readAll(l.layout_file)
    l.layout_file.close()

proc get_layout_data*(l: Layout, partialCache: Table[string, string]): string =
    result = parse_for_partials(l, partialCache)
    l.layout_file.close()
