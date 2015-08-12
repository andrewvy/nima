import jester, asyncdispatch, strutils, math, os, asyncnet, re

routes:
    get "/testing":
        resp "foo"

proc serve*(args: Table) =
    runForever()
