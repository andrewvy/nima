import types

import tables
import docopt
import os
import strutils

type
    fileItem = ref object of RootObj
        filepath: string
        filetype: string

    fileCollection = ref object of RootObj
        filetype: string
        fileitems: seq[fileItem]

proc compile_html(current_dir: string) =
    echo "Compiling HTML"

proc build_file_hash(current_dir: string) =
    var t = Table[string, fileCollection]()

    for path in walkDirRec(current_dir, {pcFile}):
        var i = fileItem()
        var c = fileCollection()
        let s = split(path, ".")
        i.filepath = path
        i.filetype = s[high(s)]

        if t[i.filetype] of fileCollection:
            t.add(i.filetype, c)

#        c = t[i.file_type]
#        if not len(c.fileitems) > 0:
#            c.fileitems = @[]

#        add(c.fileitems, i)

proc build*(args: Table) =
    let current_dir = os.getCurrentDir()
    let config_file = "config.toml"

    try:
        if existsFile(current_dir/config_file):
            echo "Building Nima project.."
            build_file_hash(current_dir)
        else:
            raise newException(NimaError, "Not currently in a Nima project!")
    except NimaError:
        echo "ERROR: " & getCurrentExceptionMsg()
