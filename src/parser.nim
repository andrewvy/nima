import types

import os
import streams
import strutils
import parsexml

proc addTemplateFile*(f: FileItem): string =
    result = ""
    result = readFile(f.path)
