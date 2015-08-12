import types
import parser

import os
import docopt
import tables
import parsexml
import strutils

proc makeDirs(dirs: seq[string]) =
    for dir in dirs:
        if not dirExists("public/" & dir): createDir("public/" & dir)

proc compile_html(c: FileCollection) =
    let files = c.fileitems
    var templateCache = init_table[string, string]()
    var directoryCache = newSeq[string]()

    for file in files:
        echo "Compiling.. " & file.filename & file.fileext
        var data = addTemplateFile(file)
        templateCache.add(file.filepath, data)

proc compile(t: Table[string, FileCollection]) =
    for key, c in t:
        case key
            of ".html": compile_html(c)
            else: discard

proc build_file_hash(current_dir: string): Table[string, FileCollection] =
    result = init_table[string, FileCollection]()

    for path in walkDirRec(current_dir):
        var i = FileItem()
        var c = FileCollection()
        let s = splitFile(path)

        i.path = path
        i.localpath = s[0].copy(len(current_dir)+1)
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
