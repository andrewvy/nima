import types

import os, streams, tables, strutils

proc addTemplateFile*(f: FileItem): File = open(f.path)
proc injectPartials*(cache: Table[string, string], filepath: string, filedata: string): string =
    result = ""
