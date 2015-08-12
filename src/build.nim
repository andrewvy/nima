import types
import parser

import os
import docopt
import tables
import parsexml
import strutils

type
    fileItem* = ref object of RootObj
        path: string
        filepath: string
        fileext: string
        filename: string

    fileCollection* = ref object of RootObj
        fileext: string
        fileitems: seq[fileItem]

proc compile_html(c: fileCollection) =
    let files = c.fileitems
    var templateCache = init_table[string, string]()
    var directoryCache = init_table[string, string]()

    for file in files:
        echo "Compiling.. " & file.filepath
        templateCache.add(file.filepath, addTemplateFile(file.path))

proc compile(t: Table[string, fileCollection]) =
    for key, c in t:
        case key
            of ".html": compile_html(c)
            else: discard

proc build_file_hash(current_dir: string): Table[string, fileCollection] =
    result = init_table[string, fileCollection]()

    for path in walkDirRec(current_dir):
        var i = fileItem()
        var c = fileCollection()
        let s = splitFile(path)

        i.path = path
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
            compile(file_hash)
        else:
            raise newException(NimaError, "Not currently in a Nima project!")
    except NimaError:
        echo "ERROR: " & getCurrentExceptionMsg()
