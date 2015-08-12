import os
import streams
import strutils
import parsexml

proc addTemplateFile*(filepath: string): string =
    result = ""
    result = readFile(filepath)
